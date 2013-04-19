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

require "commit-comment-tools"

require "optparse"

module CommitCommentTools
  class Subcommand
    def initialize
      @parser = OptionParser.new

      @parser.on_tail("-h", "--help", "Print this message and quit.") do
        $stderr.puts(@parser.help)
        exit(true)
      end
    end

    def parse(argv)
      @parser.parse!(argv)
    end

    def help
      @parser.help
    end

    def exec(global_options, argv)
    end

    def error(message)
      $stderr.puts "#{File.basename($0, '.*')}: error: #{message}"
      exit(false)
    end

    def option_error(message)
      $stderr.puts(message)
      $stderr.puts(help)
      exit(false)
    end
  end
end

module CommitCommentTools
  module Subcommands
  end
end
