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

require "commit-comment-tools/commit"

module CommitCommentTools
  class CommitsAnalyzer
    def initialize(db_path, max_lines, step, terms, format)
      @db_path = db_path
      @max_lines = max_lines
      @step = step
      @terms = terms.collect do |term|
        term.split(":").collect do |date|
          Date.parse(date)
        end
      end
      @format = format
    end

    def analyze
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: @db_path)
      commit_groups = @terms.collect do |first, last|
        Commit.where(committed_date: first..last)
      end
      n_commits_by_lines = commit_groups.collect do |commit_group|
        plot(commit_group, commit_group.count)
      end

      first, *rest = *n_commits_by_lines
      rest_values = rest.collect{|ratio_map| ratio_map.collect{|_, ratio| ratio }}

      # TODO output to file
      first.zip(*rest_values) do |(label, first_ratio), *rest_ratios|
        puts([label, first_ratio, *rest_ratios].join(","))
      end
    end

    private

    def plot(commits, total)
      distribution_map = Hash.new(0)
      commits.each do |commit|
        mod = commit.diff_lines_count % @step
        if commit.diff_lines_count <= @max_lines
          base = commit.diff_lines_count - mod
          distribution_map["#{"%03d" % [base]}..#{"%03d" % [base + @step]}"] += 1
        else
          distribution_map["over #{@max_lines}"] += 1
        end
      end

      ratio_distribution_map = {}
      distribution_map.each do |label, n_commits|
        ratio_distribution_map[label] = ((n_commits / total.to_f).round(2) * 100).to_i
      end
      ratio_distribution_map.sort_by{|label, _| label }
    end

  end
end
