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
  class ReportParser
    class << self
      def parse(report_directory=nil)
        report_directory ||= "."
        report_unexpanded_path = File.join(report_directory, "**", "*.txt")
        report_file_paths = Dir.glob(report_unexpanded_path)

        new.parse(report_file_paths)
      end
    end

    def initialize
      @person_reports = {}
    end

    def parse(report_files)
      report_files.each do |report_file|
        person_name = File.basename(report_file, ".txt")
        next unless person_name == person_name.downcase
        daily_entries = parse_file(report_file)
        @person_reports[person_name] = generate_daily_report(daily_entries)
      end

      @person_reports
    end

    def parse_file(report_file)
      File.open(report_file, "r") do |report_io|
        parse_stream(report_io)
      end
    end

    def parse_stream(report_io)
      entries = []
      date = ""
      read_ratio = ""
      comment = ""

      report_io.each_line.with_index do |line, line_number|
        case line.chomp
        when /\A(\d\d\d\d-\d+-\d+):(\d+)%:(.*)\z/
          unless line_number.zero?
            entries << entry(date, read_ratio, comment)
          end

          date = $1
          read_ratio = $2
          comment = $3
        when /\A\s+/
          comment << $POSTMATCH << "\n"
        end
      end

      unless comment.empty?
        entries << entry(date, read_ratio, comment)
      end
      entries
    end

    def entry(date, read_ratio, comment)
      {
        :date       => date,
        :read_ratio => read_ratio,
        :comment    => comment.chomp
      }
    end

    def generate_daily_report(entries)
      daily_report = {}

      entries.each do |entry|
        date = entry.delete(:date)
        daily_report[date] = entry
      end
      daily_report
    end
  end
end
