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

require "date"

module CommitCommentTools
  class Term
    class << self
      def parse(term_string)
        first, last, n_business_days = term_string.split(":")
        first = Date.parse(first)
        last = Date.parse(last)
        if n_business_days.nil?
          n_business_days = (first..last).to_a.size
        else
          n_business_days = n_business_days.to_i
        end
        new(first, last, n_business_days)
      end
    end

    attr_reader :first, :last, :n_business_days, :range

    def initialize(first, last, n_business_days)
      @first = first
      @last = last
      @range = first..last
      @n_business_days = n_business_days
    end

    def label
      @range.to_s
    end

    def ==(other)
      @first == other.first && @last == other.last && @n_business_days == other.n_business_days
    end
  end
end
