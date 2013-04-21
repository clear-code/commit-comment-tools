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

require "pathname"
require "optparse"

require "commit-comment-tools/subcommand"
require "commit-comment-tools/report-parser"
require "commit-comment-tools/entry"
require "commit-comment-tools/generator"
require "commit-comment-tools/generator/csv"

module CommitCommentTools::Subcommands
  class AnalyzeReportsCommand < CommitCommentTools::Subcommand
    def initialize
      super
      @format = :csv
      @output_filename = nil
      @parser.banner = <<-BANNER
Usage: #{$0} REPORT_DIRECTORY
 e.g.: #{$0} daily-report

Options:
      BANNER

      available_formats = [:csv, :png]
      @parser.on("-f=FORMAT", "--format=FORMAT", available_formats,
                 "Output format",
                 "available formats: [#{available_formats.join(', ')}]",
                 "[#{@format}]") do |format|
        @format = format
      end

      @parser.on("-o", "--output-filename=PATH", String, "Store CSV data to PATH.") do |path|
        @output_filename = path
      end
    end

    def exec(global_options, argv)
      unless ARGV.size == 1
        option_error("Please specify only 1 arugments for #{$0}.")
      end

      report_directory = argv.shift
      entries = CommitCommentTools::ReportParser.parse(report_directory)

      case @format
      when :csv
        generator = CommitCommentTools::Generator::CSV.new(entries)
      when :png
        raise "Not implemented yet."
      else
        raise "Must not happen! format=<#{@format}>"
      end

      output = generator.generate

      if @output_filename.nil?
        puts output
      else
        File.open(@output_filename, "w+") do |file|
          file.puts output
        end
      end
    end
  end
end
