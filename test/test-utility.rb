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

require "commit-comment-tools/utility"

class UtilityTest < Test::Unit::TestCase
  include CommitCommentTools::Utility

  def test_calculate_percentage
    assert_equal(1.0, calculate_percentage(10, 1000))
  end

  def test_calculate_percentage_division_by_zero
    assert_raise(ZeroDivisionError) do
      calculate_percentage(10, 0)
    end
  end

  def test_calculate_average
    assert_equal(10.0, calculate_average(1000, 100))
  end

  def test_calculate_average_division_by_zero
    assert_raise(ZeroDivisionError) do
      calculate_average(1000, 0)
    end
  end
end
