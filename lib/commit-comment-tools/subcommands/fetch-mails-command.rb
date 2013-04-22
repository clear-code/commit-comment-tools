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

require "commit-comment-tools/mail-fetcher"

module CommitCommentTools
  module Subcommands
    class FetchMailsCommand < Subcommand
      def initialize
        super
        @mode = :imap
        @options = {
          server: nil,
          port: 143,
          username: nil,
          password: nil,
          ssl: false,
          mailbox: "INBOX"
        }
        @terms = []
        @output_directory = nil
        @parser.banner = <<-BANNER
Usage: #{$0} [options]
  e.g: #{$0} -s imap.example.com -p 143 -u username -p password --no-ssl \\
             -t 2013-02-01:2013-02-28,2013-03-01:2013-03-31 \\
             -m commit -d /tmp/mails
    BANNER

        @parser.separator("")
        @parser.separator("Options:")

        available_modes = [:imap, :pop]
        @parser.on("-M=MODE", "--mode=MODE", available_modes, "Fetch mails via MODE",
                   "available modes #{available_modes.join(', ')}", "[#{@mode}]") do |mode|
          @mode = mode
        end

        @parser.on("-s=ADDRESS", "--server=ADDRESS", String, "IMAP server address.") do |server|
          @options[:server] = server
        end

        @parser.on("-P=PORT", "--port=PORT", Integer, "Port number. [143]") do |port|
          @options[:port] = port
        end

        @parser.on("-u=USERNAME", "--username=USERNAME", "User name for IMAP login.") do |username|
          @options[:username] = username
        end

        @parser.on("-p=PASSWORD", "--password=PASSWORD", "Password for IMAP login.") do |password|
          @options[:password] = password
        end

        @parser.on("--[no-]ssl", "Use SSL [false]") do |ssl|
          @options[:ssl] = ssl
        end

        @parser.on("-m=MAILBOX", "--mailbox=MAILBOX", String, "IMAP mailbox name. [INBOX]") do |mailbox|
          @options[:mailbox] = mailbox
        end

        @parser.on("-t", "--terms=TERM1,TERM2,TERM3,", Array,
                   "Analyze commits in these terms.") do |terms|
          @terms = terms.collect do |term_string|
            Term.parse(term_string)
          end
        end

        @parser.on("-o=DIR", "--output-directory=DIR", String, "Store mails in DIR") do |directory|
          @output_directory = directory
        end
      end

      def exec(global_options, argv)
        fetcher = MailFetcher.new(@mode, @terms, @output_directory, @options)
        fetcher.fetch
      end
    end
  end
end
