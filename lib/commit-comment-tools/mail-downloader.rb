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

module CommitCommentTools
  class MailDownloader
    def initialize(mode, terms, outputdir, options)
      @mode = mode
      @terms = terms.collect do |term|
        term.split(":").collect do |date|
          Date.parse(date)
        end
      end
      @outputdir = outputdir
      @options = options
    end

    def download
      case @mode
      when :imap
        download_via_imap
      when :pop
        download_via_pop
      else
        raise "must not happen! mode=<#{@mode}>"
      end
    end

    def download_via_imap
      imap = Net::IMAP.new(@options[:server], @options[:port], @options[:ssl])
      imap.login(@options[:username], @options[:password])
      imap.select(@options[:mailbox])

      threads = []
      @outputdir
      @terms.each do |first, last|
        range = first..last
        dir = File.join(@outputdir, range.to_s)
        FileUtils.mkdir_p(dir)
        threads << Thread.start(first, last) do |_first, _last|
          ids = imap.search(filter(_first, _last))
          imap.fetch(ids, ["RFC822"]).each do |mail|
            filename = "%s.eml" % Time.now.strftime("%s%N")
            Dir.chdir(dir) do
              File.open(filename, "wb+") do |file|
                file.puts mail.attr["RFC822"]
              end
            end
          end
        end
      end
      threads.each(&:join)

      imap.logout
      imap.disconnect
    end

    def download_via_pop
      raise "Not implemented!"
    end

    private

    def filter(first, last)
      ["SINCE", first.strftime("%d-%b-%Y"), "BEFORE", last.strftime("%d-%b-%Y")]
    end
  end
end
