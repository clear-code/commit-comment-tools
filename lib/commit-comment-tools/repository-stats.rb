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

    class CommitGroup
      attr_reader :branch_name, :key, :commits

      def initialize(branch_name, key, commits)
        @branch_name = branch_name
        @key = key
        @commits = commits
      end

      def size
        @commits.size
      end

      def diff_lines_count
        @diff_lines_count ||= commits.inject(0) do |memo, commit|
          memo + commit.diff_lines_count
        end
      end

      def diff_bytesize
        @diff_bytesize ||= commits.inject(0) do |memo, commit|
          memo + commit.diff_bytesize
        end
      end
    end

    def initialize(repository_path, branch_prefix, resolution=:day)
      @repository = Grit::Repo.new(repository_path)
      @target_branches = @repository.remotes.select do |branch|
        /\A#{Regexp.quote(branch_prefix)}/ =~ branch.name
      end
      @resolution = resolution
    end

    def stats
      # TODO format data
      case @resolution
      when :day
        commit_groups = commit_groups_by_date
      when :week
        commit_groups = commit_groups_by_week
      when :month
        commit_groups = commit_groups_by_month
      end
      # TODO make simple
      commit_groups.group_by do |commit_group|
        commit_group.branch_name
      end.each do |branch_name, commit_groups|
        puts branch_name
        commit_groups.sort_by do |group|
          group.key
        end.each do |group|
          puts "#{group.key},#{group.size},#{group.diff_lines_count},#{group.diff_bytesize}"
        end
      end
    end

    def commit_groups_by_date
      create_commit_groups("%Y-%m-%d")
    end

    def commit_groups_by_week
      create_commit_groups("%Y-%Uw")
    end

    def commit_groups_by_month
      create_commit_groups("%Y-%m")
    end

    def create_commit_groups(key_format="%Y-%m-%d")
      @target_branches.map do |branch|
        create_commit_group(branch.name, key_format)
      end.flatten
    end

    def create_commit_group(branch_name, key_format="%Y-%m-%d")
      # TODO Use Grit::Commit.find_all
      groups = @repository.commits(branch_name, nil).group_by do |commit|
        commit.date.strftime(key_format)
      end
      groups.map do |key, commits|
        CommitGroup.new(branch_name, key, commits)
      end
    end
  end
end
