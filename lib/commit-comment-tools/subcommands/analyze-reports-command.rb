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
require "commit-comment-tools/generator/graph"
require "commit-comment-tools/generator/summary"

module CommitCommentTools
  module Subcommands
    class AnalyzeReportsCommand < Subcommand
      def initialize
        super
        @format = :csv
        @output_filename = nil
        prepare
      end

      def prepare
        @parser.banner = <<-BANNER
Usage: #{$0} REPORT_DIRECTORY
 e.g.: #{$0} daily-report
        BANNER

        @parser.separator("")
        @parser.separator("Options:")

        available_formats = [:csv, :png, :summary]
        @parser.on("-f", "--format=FORMAT", available_formats,
                   "Output format",
                   "available formats: [#{available_formats.join(', ')}]",
                   "[#{@format}]") do |format|
          @format = format
        end

        @parser.on("-o", "--output-filename=PATH", String, "Store CSV data to PATH.") do |path|
          @output_filename = path
        end

        @parser.on("-m", "--members=MEMBER1,MEMBER2,...", Array, "Members") do |members|
          @members = members
        end

        @parser.on("-t", "--terms=TERM1,TERM2,TERM3,", Array,
                   "Analyze commits in these terms.") do |terms|
          @terms = terms.collect do |term_string|
            Term.parse(term_string)
          end
        end

        @parser.on("-i", "--mail-info=PATH", String, "Commit mail information.") do |path|
          @commit_mail_info = Pathname(path).realpath.to_s
        end
      end

      def exec(global_options, argv)
        unless ARGV.size == 1
          option_error("Please specify only 1 arugments for #{$0}.")
        end

        report_directory = argv.shift
        entries = ReportParser.parse(report_directory)

        case @format
        when :csv
          generator = Generator::CSV.new(entries)
        when :png
          # generator = Generator::Graph.new(entries,
          #                                  output_filename: @output_filename,
          #                                  members: @members)
        when :summary
          generator = Generator::Summary.new(entries,
                                             members: @members,
                                             terms: @terms,
                                             commit_mail_info: @commit_mail_info)
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
end
