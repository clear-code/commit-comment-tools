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

require "commit-comment-tools/report-normalizer"

class TestReportNormalizer < Test::Unit::TestCase
  def setup
    @normalizer = CommitCommentTools::ReportNormlizer.new
  end

  def test_normalize
    daily_report = {
      "2013-1-30" => {
        :read_ratio => "40",
        :comment    => "特になし"
      },
      "2013-2-1" => {
        :read_ratio => "80",
        :comment    => "typoが多かった"
      }
    }
    person_report = {"yamada" => daily_report}
    actual_report = @normalizer.normalize(person_report)
    assert_normalize_report(actual_report)
  end

  def test_normalize_daily_report_with_zero_padding
    daily_report = {
      "2013-1-30" => {
        :read_ratio => "40",
        :comment    => "特になし"
      },
      "2013-2-1" => {
        :read_ratio => "80",
        :comment    => "typoが多かった"
      }
    }
    actual_report = @normalizer.normalize_daily_report("yamada", daily_report)
    assert_normalize_report(actual_report)
  end

  def test_normalize_daily_report_without_zero_padding
    daily_report = {
      "2013-1-30" => {
        :read_ratio => "40",
        :comment    => "特になし"
      },
      "2013-2-1" => {
        :read_ratio => "80",
        :comment    => "typoが多かった"
      }
    }
    actual_report = @normalizer.normalize_daily_report("yamada", daily_report)
    assert_normalize_report(actual_report)
  end

  def assert_normalize_report(actual_report)
    expected_report = {
      "yamada" =>
      {"2013-01-30" =>
        {
          :read_ratio => 40,
          :comment => "特になし"
        },
        "2013-02-01" =>
        {:read_ratio => 80,
          :comment => "typoが多かった"
        }
      }
    }
    assert_equal(expected_report, actual_report)
  end
end
