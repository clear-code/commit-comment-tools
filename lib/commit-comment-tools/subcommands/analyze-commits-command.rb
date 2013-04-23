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

require "active_record"
require "optparse"
require "pathname"

require "commit-comment-tools/commits-analyzer"

module CommitCommentTools
  module Subcommands
    class AnalyzeCommitsCommand < Subcommand
      def initialize
        super
        @db_path = nil
        @step = 50
        @max_lines = 300
        @format = :csv
        @mode = :pareto
        @output_filename = nil
        @terms = []
        @all = false
        prepare
      end

      def prepare
        @parser.banner = <<-BANNER
Usage: #{$0} [options]
  e.g: #{$0} -d ./commits.db
        BANNER

        @parser.separator("")
        @parser.separator("Options:")

        @parser.on("-d=PATH", "--database=PATH", String, "Database path.") do |path|
          @db_path = Pathname(path).expand_path.to_s
        end

        @parser.on("-M=MAX_LINES", "--max=MAX_LINES", Integer,
                   "Max lines of diff. [#{@max_lines}]") do |max_lines|
          @max_lines = max_lines
        end

        @parser.on("-s=STEP", "--step=STEP", Integer, "Step. [#{@step}]") do |step|
          @step = step
        end

        @parser.on("-t", "--terms=TERM1,TERM2,TERM3,", Array,
                   "Analyze commits in these terms.") do |terms|
          @terms = terms.collect do |term_string|
            Term.parse(term_string)
          end
        end

        available_formats = [:csv, :png]
        @parser.on("-f=FORMAT", "--format=FORMAT", available_formats,
                   "Output format",
                   "available formats: [#{available_formats.join(', ')}]",
                   "[#{@format}]") do |format|
          @format = format
        end

        available_modes = [:pareto, :average]
        @parser.on("-m=MODE", "--mode=MODE", available_modes,
                   "Output mode",
                   "available modes: [#{available_modes.join(', ')}]",
                   "[#{@mode}]") do |mode|
          @mode = mode
        end

        @parser.on("-o=PATH", "--output-filename=PATH", String, "Output filename.") do |path|
          @output_filename = Pathname(path).expand_path.to_s
        end

        @parser.on("-a", "--all", "Include all commits.",
                   "This option is effective in pareto mode only.") do
          @all = true
        end
      end

      def parse(argv)
        super
        option_error("Must specify --database option") if @db_path.nil?
        options_error("Must specify --terms option") if @terms.empty?
      end

      def exec(global_options, argv)
        analyzer = CommitsAnalyzer.new(@db_path, @max_lines, @step, @terms, @format, @all)
        case @mode
        when :pareto
          csv_string = analyzer.pareto
        when :average
          csv_string = analyzer.average
        end
        if @output_filename
          File.open(@output_filename, "w+") do |file|
            file.puts csv_string
          end
        else
          puts csv_string
        end
      end
    end
  end
end
