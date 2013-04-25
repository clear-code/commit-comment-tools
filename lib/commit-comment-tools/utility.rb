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

require "csv"

require "commit-comment-tools"

module CommitCommentTools
  module Utility
    def calculate_percentage(amount, total_amount)
      raise ZeroDivisionError if total_amount == 0
      ((amount / total_amount.to_f) * 100).round(2)
    end

    def calculate_average(total, n_elements)
      raise ZeroDivisionError if n_elements == 0
      (total / n_elements.to_f).round(2)
    end

    def commit_average(path, term)
      ::CSV.foreach(path, headers: true) do |row|
        if row["TERM"] == term.label
          return row["average(commit)"]
        end
      end
    end
  end
end
