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

require "commit-comment-tools/term"

module CommitCommentTools
  class MailCounter
    def initialize(directory, terms, reply_from_patterns)
      @directory = directory
      @terms = terms
      @reply_from_patterns = reply_from_patterns
    end

    def count
      count_map = {}
      @terms.each do |term|
        maildir = File.join(@directory, term.label)
        count_map[term.label] = Hash.new(0)
        Dir.glob("#{maildir}/*.eml") do |entry|
          mail = File.read(entry).force_encoding("binary")
          if mail.match(/^In-Reply-To:/i)
            count_map[term.label]["n_reply_mails"] += 1
            @reply_from_patterns.each do |group_name, pattern|
              count_map[term.label][group_name] += 1 if mail.match(pattern)
            end
          else
            count_map[term.label]["n_original_mails"] += 1
          end
        end
      end

      CSV.generate do |csv|
        csv << ["TERM", "average(commit)", *@reply_from_patterns.keys.sort, "average(reply)"]
        count_map.each do |label, row_map|
          row_map = row_map.dup
          n_reply_mails = row_map.delete("n_reply_mails")
          n_original_mails = row_map.delete("n_original_mails")
          n_comments_list = row_map.sort_by{|group_name, _| group_name }.collect(&:last)
          csv << [label, n_original_mails, *n_comments_list, n_reply_mails]
        end
      end
    end
  end
end
