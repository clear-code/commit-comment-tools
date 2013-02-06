# -*- coding: utf-8 -*-
#
# Copyright (C) 2013  Haruka Yoshihara <yoshihara@clear-code.com>
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

require "English"

module CommitCommentTools
  class Parser
    class << self
      def parse(arguments)
      end
    end

    def initialize
    end

    def parse_files(report_files)
    end

    def parse_stream(name, report)
    end

def store(name, date, read_ratio, comment)
  unless comment.empty?
    @parsed_reports[name][date] =
      {:read_ratio => read_ratio, :comment => comment.chomp}
  end
end
  end
end
