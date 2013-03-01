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

require "date"

module CommitCommentTools

  class Entry
    class InvalidEntryError < StandardError
    end

    attr_reader :name, :date, :read_ratio, :comment

    def initialize(name, entry_chunk)
      @name = name
      @date = nil
      @read_ratio = nil
      @comment = nil

      if /\A(\d\d\d\d-\d+-\d+):(\d+)%:(.*)\z/m =~ entry_chunk
        @date = Date.parse($1).strftime("%Y-%m-%d")
        @read_ratio = $2.to_i
        @comment = $3
      else
        valid_format = "DATE:READ_RATIO%:COMMENT"
        error_message = "The expected format of entry like below:\n" +
                          "\"#{valid_format}\", but was \"#{entry_chunk}\"."
        raise(InvalidEntryError, error_message)
      end
    end
  end
end
