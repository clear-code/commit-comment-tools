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

require "commit-comment-tools/term"

module CommitCommentTools
  class TermTest < Test::Unit::TestCase
    data("with out business days" => ["2013-03-01:2013-03-31",
                                      Term.new(Date.parse("2013-03-01"),
                                               Date.parse("2013-03-31"),
                                               31)],
         "with business days"     => ["2013-03-01:2013-03-31:10",
                                      Term.new(Date.parse("2013-03-01"),
                                               Date.parse("2013-03-31"),
                                               10)],)
    def test_term_parse(data)
      target, expected = data
      actual = Term.parse(target)
      assert_equal(expected, actual)
    end
  end
end
