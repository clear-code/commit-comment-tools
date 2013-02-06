# -*- coding: utf-8 -*-
#
# Copyright (C) 2013  Haruka Yoshihara <yoshihara@clear-code.com>
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

require "English"

module CommitCommentTools
  class Parser
    class << self
      def parse(argument=nil)
        report_directory = argument || "."
        report_files = Dir.glob(File.join(report_directory, "**", "*.txt"))

        self.new.parse_files(report_files)
      end
    end

    def initialize
      @parsed_reports = {}
    end

    def parse_files(report_files)
      report_files.each do |report_file|
        name = File.basename(report_file, ".txt")
        File.open(report_file, "r") do |report|
          parse_stream(name, report)
        end
      end
    end

    def parse_stream(name, report)
      @parsed_reports[name] = {}
      date = ""
      read_ratio = ""
      comment = ""

      report.each_line.with_index do |_line, line_number|
        line = _line.chomp
        case line
        when /\A(\d\d\d\d-\d+-\d+):(\d+)%:(.*)\z/
          unless line_number.zero?
            store(name, date, read_ratio, comment)
          end

          date = $1
          read_ratio = $2
          comment = $3
        when /\A\s+/
          comment << $POSTMATCH << "\n"
        end
      end

      unless comment.empty?
        store(name, date, read_ratio, comment)
      end

      @parsed_reports
    end

    def store(name, date, read_ratio, comment)
      @parsed_reports[name][date] =
        {:read_ratio => read_ratio, :comment => comment.chomp}
    end
  end
end
