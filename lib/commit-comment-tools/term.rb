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

module CommitCommentTools
  class Term
    class << self
      def parse(term_string)
        first, last, n_business_days = term_string(":")
        new(Date.parse(first), Date.parse(last), n_business_days.to_i)
      end
    end

    attr_reader :first, :last, :n_business_days, :range

    def initialize(first, last, n_business_days)
      @first = first
      @last = last
      @n_business_days = n_business_days
      @range = first..last
    end

    def label
      @range.to_s
    end
  end
end