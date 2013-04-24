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

require "csv"
require "date"

require "commit-comment-tools/utility"

module CommitCommentTools
  module Generator
    class Summary
      include CommitCommentTools::Utility

      def initialize(entries, options={})
        @entries = entries
        @options = options
        @members = options[:members]
        @terms = options[:terms]
        @commit_mail_info = options[:commit_mail_info]
      end

      def generate
        ::CSV.generate do |csv|
          csv << ["#TERM", "average(commit)", "read ratio(%)", "comment ratio(%)"]
          @terms.each do |term|
            target_entries = @entries.select do |entry|
              @members.include?(entry.name) and term.include?(Date.parse(entry.date))
            end
            total_read_ratio = target_entries.inject(0) do |memo, entry|
              memo + entry.read_ratio
            end
            n_comments = target_entries.inject(0) do |memo, entry|
              case
              when entry.comment.empty?
                memo
              else
                memo + 1
              end
            end
            n_entries = term.n_business_days * @members.size
            csv << [term.label,
                    commit_average(@commit_mail_info, term),
                    calculate_average(total_read_ratio, n_entries),
                    calculate_percentage(n_comments, n_entries)]
          end
        end
      end
    end
  end
end
