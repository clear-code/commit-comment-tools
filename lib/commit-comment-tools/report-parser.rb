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
      @entries = []
      @person_reports = {}
    end

    def parse(report_files)
      report_files.each do |report_file|
        parse_file(report_file)
      end
      @entries
    end

    def parse_file(report_file)
      name = File.basename(report_file, ".txt")
      return unless name == name.downcase
      File.open(report_file, "r") do |report_io|
        parse_stream(name, report_io)
      end
    end

    def parse_stream(name, report_io)
      chunks = []
      chunk = ""
      report_io.each_line do |line|
        case line
        when /\A\s/
          chunk << line.lstrip
        else
          chunks << chunk unless chunk.empty?
          chunk = line.chomp
        end
      end
      chunks << chunk unless chunk.empty?
      chunks.each do |chunk|
        @entries << Entry.new(name, chunk.chomp)
      end
      @entries
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
