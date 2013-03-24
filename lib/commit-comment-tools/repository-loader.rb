require "grit"
require "active_record"

Grit::Git.git_timeout  = 30 # timeout in secs
Grit::Git.git_max_size = 2 * 1024 * 1024 # size in bytes (2MB)

module Grit
  class Commit
    def diff_bytesize
      @diff_bytesize ||= diffs.inject(0) do |memo, _diff|
        memo + _diff.diff.bytesize
      end
    end

    def diff_lines_count
      @diff_lines_count ||= diffs.inject(0) do |memo, _diff|
        memo + _diff.diff.lines.to_a.size
      end
    end
  end
end

module CommitCommentTools
  class Commit < ActiveRecord::Base
  end

  class RepositoryLoader
    def initialize(repository_path, base_branch_name, branch_name="")
      create_table
      @repository_path = repository_path
      @repository = Grit::Repo.new(repository_path)
      @repository_name = File.basename(repository_path)
      @base_branch_name = base_branch_name
      @target_branches = @repository.remotes.select do |branch|
        branch_name === branch.name
      end
    end

    def load_commits
      puts @repository_name
      load_base_branch_commits
      @target_branches.each do |branch|
        load_branch_commits(branch.name)
      end
    end

    private

    def load_base_branch_commits
      n_commits = 0
      n_records = 0
      skip = Commit.where(repository_name: @repository_name,
                          branch_name: @base_branch_name).count
      @repository.commits(@base_branch_name, nil, skip).each do |commit|
        n_commits += 1
        next if Commit.where(repository_name: @repository_name,
                             branch_name: @base_branch_name,
                             commit_hash: commit.id).exists?
        begin
          create_commit(@base_branch_name, commit)
          n_records += 1
        rescue Grit::Git::GitTimeout => ex
          $stderr.puts "#{ex.message}:#{@repository_name}:#{@base_branch_name}:#{commit.id}:#{commit.committed_date}"
        end
      end
      puts "#{@base_branch_name}:#{n_records}/#{n_commits}, skip=#{skip}"
    end

    def load_branch_commits(branch_name)
      n_commits = 0
      n_records = 0
      base_commit_id = base_commit(branch_name)
      @repository.commits_between(base_commit_id, branch_name).each do |commit|
        n_commits += 1
        next if Commit.where(repository_name: @repository_name,
                             branch_name: branch_name,
                             commit_hash: commit.id).exists?
        begin
          create_commit(branch_name, commit)
          n_records += 1
        rescue Grit::Git::GitTimeout => ex
          $stderr.puts "#{ex.message}:#{commit.id}:#{commit.committed_date}"
        end
      end
      puts "#{branch_name}:#{base_commit_id}:#{n_records}/#{n_commits}"
    end

    def create_commit(branch_name, commit)
      Commit.create(repository_name:   @repository_name,
                    branch_name:       branch_name,
                    commit_hash:       commit.id,
                    commit_message:    commit.message,
                    committer_name:    commit.committer.name,
                    committer_email:   commit.committer.email,
                    committed_date:    commit.committed_date,
                    diff_lines_count:  commit.diff_lines_count,
                    diff_bytesize:     commit.diff_bytesize)
    end

    def base_commit(branch_name)
      log = ""
      Dir.chdir(@repository_path) do
        log = `git show-branch --sha1-name #{@base_branch_name} #{branch_name} | tail -1`
      end
      log[/\[(.+?)\]/, 1]
    end

    def create_table
      return if Commit.table_exists?
      ActiveRecord::Schema.define(:version => 1) do
        create_table "commits", :force => false do |t|
          t.string   "repository_name"
          t.string   "branch_name"
          t.string   "commit_hash"
          t.text     "commit_message"
          t.string   "committer_name"
          t.string   "committer_email"
          t.datetime "committed_date"
          t.integer  "diff_lines_count"
          t.integer  "diff_bytesize"
        end

        add_index("commits",
                  ["repository_name", "branch_name", "commit_hash"],
                  :name => "index_commits_on_commit_hash",
                  :unique => true)
      end
    end
  end
end

