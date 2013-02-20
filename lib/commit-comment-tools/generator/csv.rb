# -*- coding: utf-8 -*-
#
# Copyright (C) 2013  Kenji Okimoto <okimoto@clear-code.com>
# Copyright (C) 2013  Kouhei Sutou <kou@clear-code.com>
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

module CommitCommentTools
  module Generator
    class CSV
      def initialize(reports, options={})
        @reports = reports
        @options = options
      end

      def generate
        members = []
        daily_read_ratios = {}
        @reports.each do |name, diaries|
          members << name
          diaries.each do |date, report|
            daily_read_ratios[date] ||= {}
            daily_read_ratios[date][name] = report[:read_ratio]
          end
        end
        sorted_members = members.sort
        csv_string = generate_csv(sorted_members, daily_read_ratios)
        # TODO write to file
        puts csv_string
      end

      private
      def generate_csv(members, daily_read_ratios)
        ::CSV.generate do |csv|
          csv << ["DATE", *members]
          daily_read_ratios.sort_by {|date, _| date}.each do |date, read_ratios|
            row_values = daily_record2row(read_ratios, members)
            csv << [date, *row_values]
          end
        end
      end

      def daily_record2row(read_ratios, members)
        members.collect do |name|
          read_ratios[name] || 0
        end
      end
    end
  end
end
