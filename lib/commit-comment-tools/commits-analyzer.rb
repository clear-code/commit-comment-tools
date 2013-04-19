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

module CommitCommentTools
  class CommitsAnalyzer
    def initialize(db_path, max_lines, step, terms, format)
      @db_path = db_path
      @max_lines = max_lines
      @step = step
      @ranges = create_ranges(max_lines, step)
      @terms = terms.collect do |term|
        term.split(":").collect do |date|
          Date.parse(date)
        end
      end
      check_terms(@terms)
      @format = format
    end

    def pareto
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: @db_path)

      commit_groups = @terms.collect do |first, last; range|
        range = first..last
        Commit.where(committed_date: range)
      end

      csv_string = CSV.generate do |csv|
        csv << ["TERM", *create_header(@terms)]
        @ranges.each do |range; ratio_list|
          ratio_list = calculate_ratios(commit_groups, {diff_lines_count: range})
          csv << [range.to_s, *ratio_list]
        end
        over_max_ratio_list = calculate_ratios(commit_groups, ["diff_lines_count > ?", @max_lines])
        csv << ["over #{@max_lines}", *over_max_ratio_list]
        csv << ["TOTAL", *commit_groups.collect(&:count)]
      end

      puts csv_string
    end

    def average
    end

    private

    def create_header(terms)
      terms.collect do |first, last|
        (first..last).to_s
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

    def check_terms(terms)
      unless terms.all?{|term| term.size == 2 }
        $stderr.puts "Invalid terms: #{terms_string(terms)}"
        exit(false)
      end
      unless terms.flatten.all?{|date| date.is_a?(Date) }
        $stderr.puts "Invalid terms: #{terms_string(terms)}"
        exit(false)
      end
    end

    def terms_string(terms)
      terms.collect{|term| term.join(':') }.join(',')
    end

    def calculate_ratios(commit_groups, condition)
      commit_groups.collect do |commit_group; n_commits, n_total_commits|
        n_commits = commit_group.where(condition).count
        n_total_commits = commit_group.count
        calculate_ratio(n_commits, n_total_commits)
      end
    end

    def calculate_ratio(n_commits, n_total_commits)
      ((n_commits / n_total_commits.to_f) * 100).round(2)
    end
  end
end
