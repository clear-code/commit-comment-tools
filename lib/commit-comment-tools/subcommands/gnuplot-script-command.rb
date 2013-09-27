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

module CommitCommentTools
  module Subcommands
    class GnuplotScriptCommand < Subcommand
      def initialize
        super
        prepare
      end

      def prepare
        @parser.banner <<-BANNER
Usage: #{$0} [options]
  e.g: #{$0} --input-file=xxx.csv --output-file=xxx.png --template=pareto
        BANNER

        @parser.separator("")
        @parser.separator("Options:")

        @parser.on("-i", "--input-file=CSV", String)
      end
    end
  end
end

