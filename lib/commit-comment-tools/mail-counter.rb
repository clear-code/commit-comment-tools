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

require "net/imap"
require "csv"

module CommitCommentTools
  class MailCounter
    def initialize(terms, reply_from_patterns, options)
      @terms = terms.collect do |term|
        term.split(":").collect do |date|
          Date.parse(date)
        end
      end
      @reply_from_patterns = reply_from_patterns

      @imap = Net::IMAP.new(options[:server], options[:port], options[:ssl])
      @imap.login(options[:username], options[:password])
      @imap.select(options[:mailbox])
    end

    def count
      search_threads = []
      ids_map = {}
      @terms.each do |first, last|
        range = first..last
        search_threads << Thread.start(first, last) do |_first, _last|
          ids_map[range.to_s] = @imap.search(filter(_first, _last))
        end
      end
      search_threads.each(&:join)
      count_map = {}
      ids_map.each do |label, ids|
        count_map[label] = Hash.new(0)
        @imap.fetch(ids, ["RFC822.HEADER"]).each do |mail|
          header = mail.attr["RFC822.HEADER"]
          if header.match(/^In-Reply-To/im)
            count_map[label]["n_reply_mails"] += 1
            @reply_from_patterns.each do |group_name, pattern|
              count_map[label][group_name] += 1 if header.match(pattern)
            end
          else
            count_map[label]["n_original_mails"] += 1
          end
        end
      end
      # TODO generate CSV
      pp count_map
    end

    private

    def filter(first, last)
      ["SINCE", first.strftime("%d-%b-%Y"), "BEFORE", last.strftime("%d-%b-%Y")]
    end
  end
end
