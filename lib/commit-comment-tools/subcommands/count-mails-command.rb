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

require "optparse"
require "pathname"

require "commit-comment-tools/mail-counter"

module CommitCommentTools
  module Subcommands
    class CountMailsCommand < Subcommand
      def initialize
        super
        @directory = nil
        @output_filename = nil
        @terms = []
        @reply_from_patterns = {}
        @parser.banner = <<-BANNER
Usage: #{$0} count-mails [options]
  e.g: #{$0} count-mails -d ./mails -o ./reports/commit-mail.csv \\
             --reply-from-patterns @example.com:/^From:.*?@example\\.com/,@example.net:/^From:.*@example\\.net/

Options:
      BANNER

        @parser.on("-d", "--directory=DIR", String, "Load mails from DIR.") do |dir|
          @directory = dir
        end

        @parser.on("-o", "--output-filename=PATH", String, "Store CSV data to PATH.") do |path|
          @output_filename = path
        end

        @parser.on("-t", "--terms=TERM1,TERM2,TERM3,", Array,
                   "Analyze commits in these terms.") do |terms|
          @terms = terms.collect do |term_string|
            Term.parse(term_string)
          end
        end

        @parser.on("--reply-from-patterns=LABEL:PATTERN,...", Array,
                   "Reply from address patterns.") do |label_patterns|
          label_patterns.each do |label_pattern|
            label, pattern = label_pattern.split(":", 2)
            pattern = pattern.slice(%r!\A/(.*)/\z!, 1)
            if pattern
              @reply_from_patterns[label] = Regexp.new(pattern)
            else
              option_error("No pattern found!!")
            end
          end
        end
      end

      def exec(global_options, argv)
        mail_counter = MailCounter.new(@directory, @terms, @reply_from_patterns)
        if @output_filename
          File.open(@output_filename, "wb+") do |file|
            file.puts mail_counter.count
          end
        else
          puts mail_counter.count
        end
      end
    end
  end
end
