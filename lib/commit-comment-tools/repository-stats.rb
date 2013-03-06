require "grit"
require "pp"

# TODO move this monkey patch
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

    def autor_name
      author.name
    end
  end
end

module CommitCommentTools
  class RepositoryStats
    def initialize(repository_path, branch_prefix)
      @repository = Grit::Repo.new(repository_path)
      @branch_prefix = branch_prefix
      @target_branches = @repository.remotes.select do |branch|
        %r!\Aorigin/#{@branch_prefix}! =~ branch.name or %r!origin(?:/svn)?/trunk\z! =~ branch.name
      end
    end

    def stats
      stats_by_date
      stats_by_week
      stats_by_month
    end

    def stats_by(key)
      @target_branches.each do |branch|
        puts branch.name
        # TODO format data
        pp commit_count(branch.name, key)
        pp commit_diff_lines(branch.name, key)
        pp commit_diff_bytesize(branch.name, key)
      end
    end

    def stats_by_date
      stats_by("%Y-%m-%d")
    end

    def stats_by_week
      stats_by("%Y-%m")
    end

    def stats_by_month
      stats_by("%Y-%Uw")
    end

    def group_by_key(branch_name, key="%Y-%m-%d")
      # TODO Use Grit::Commit.find_all
      groups = @repository.commits(branch_name, nil).group_by do |commit|
        commit.date.strftime(key)
      end
      groups.each do |k, commits|
        yield k, commits
      end
    end

    def commit_count(branch_name, key="%Y-%m-%d")
      # TODO fix variable name
      h = {}
      group_by_key(branch_name, key) do |k, commits|
        h[k] = commits.size
      end
      h
    end

    def commit_diff_lines(branch_name, key="%Y-%m-%d")
      # TODO fix variable name
      h = {}
      group_by_key(branch_name, key) do |k, commits|
        h[k] = commits.inject(0) do |memo, commit|
          memo + commit.diff_lines_count
        end
      end
      h
    end

    def commit_diff_bytesize(branch_name, key="%Y-%m-%d")
      # TODO fix variable name
      h = {}
      group_by_key(branch_name, key) do |k, commits|
        h[k] = commits.inject(0) do |memo, commit|
          memo + commit.diff_bytesize
        end
      end
      h
    end
  end
end
