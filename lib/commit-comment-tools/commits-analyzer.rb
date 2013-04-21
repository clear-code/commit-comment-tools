# -*- coding: utf-8 -*-
#
# Copyright (C) 2013  Kenji Okimoto <okimoto@clear-code.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "date"
require "csv"

require "commit-comment-tools/commit"
require "commit-comment-tools/term"
require "commit-comment-tools/utility"

module CommitCommentTools
  class CommitsAnalyzer
    include CommitCommentTools::Utility

    def initialize(db_path, max_lines, step, terms, format)
      @db_path = db_path
      @max_lines = max_lines
      @step = step
      @ranges = create_ranges(max_lines, step)
      @terms = terms
      @format = format
    end

    def pareto
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: @db_path)

      commit_groups = @terms.collect do |term|
        Commit.where(committed_date: term.range)
      end

      ::CSV.generate do |csv|
        csv << ["#TERM", *create_header(@terms), *create_header(@terms, "(stacked)")]
        memo = []
        @ranges.each do |range|
          ratio_list = calculate_ratios(commit_groups, {diff_lines_count: range})
          if memo.empty?
            memo = ratio_list
          else
            memo = memo.zip(ratio_list).collect do |a, b|
              (a + b).round(2)
            end
          end
          csv << [range.to_s, *ratio_list, *memo]
        end
        over_max_ratio_list = calculate_ratios(commit_groups, ["diff_lines_count > ?", @max_lines])
        memo = memo.zip(over_max_ratio_list).collect do |a, b|
          (a + b).round(2)
        end
        csv << ["over #{@max_lines}", *over_max_ratio_list, *memo]
        csv << ["#TOTAL", *commit_groups.collect(&:count)]
      end
    end

    def average
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: @db_path)

      ::CSV.generate do |csv|
        csv << ["#Average", "コミット数", "lines"]
        @terms.each do |term|
          commit_group = Commit.where(committed_date: term.range).where("diff_lines_count <= ?", 300)
          n_commits = commit_group.count
          n_days = commit_group.all.group_by{|commit| commit.committed_date.strftime("%Y%m%d") }.size
          n_lines = commit_group.sum(:diff_lines_count)
          csv << [term.label,
                  calculate_average(n_commits, n_days),
                  calculate_average(n_lines, n_commits)]
        end
      end
    end

    private

    def create_header(terms, suffix="")
      terms.collect do |term|
        "#{term.label}#{suffix}"
      end
    end

    def create_ranges(max_lines, step)
      0.step(max_lines - step, step).collect do |n|
        if n == 0
          n..(n + step)
        else
          (n + 1)..(n + step)
        end
      end
    end

    def calculate_ratios(commit_groups, condition)
      commit_groups.collect do |commit_group|
        n_commits = commit_group.where(condition).count
        n_total_commits = commit_group.count
        calculate_ratio(n_commits, n_total_commits)
      end
    end
  end
end
