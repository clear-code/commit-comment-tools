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

require "stringio"
require "commit-comment-tools/report-parser"

class ReportParserTest < Test::Unit::TestCase
  def setup
    @parser = CommitCommentTools::ReportParser.new
  end

  def test_oneline
    report_io = StringIO.new(<<-REPORT)
2013-1-30:40%:特になし
2013-2-1:80%:typoが多かった
REPORT

    actual_entries = @parser.parse_stream("taro", report_io)
    expected_entries = [
      {:name => "taro", :date => "2013-01-30", :read_ratio => 40, :comment => "特になし"},
      {:name => "taro", :date => "2013-02-01",  :read_ratio => 80, :comment => "typoが多かった"},
    ]
    assert_equal(expected_entries, actual_entries.collect(&:to_hash))
  end

  def test_continues_lines
    report_io = StringIO.new(<<-REPORT)
2013-2-1:80%:typoが多かった
2013-2-2:50%:
  PHPのコードを久しぶりに書いた
  データ駆動を使ってテストがどんどん書き直されていた
REPORT

    actual_entries = @parser.parse_stream("taro", report_io)
    continues_comment = "PHPのコードを久しぶりに書いた\n" +
                          "データ駆動を使ってテストがどんどん書き直されていた"
    expected_entries = [
      {:name => "taro", :date => "2013-02-01", :read_ratio => 80, :comment => "typoが多かった"},
      {:name => "taro", :date => "2013-02-02", :read_ratio => 50, :comment => continues_comment},
    ]
    assert_equal(expected_entries, actual_entries.collect(&:to_hash))
  end

  def test_zero_padding_date
    report_io = StringIO.new("2013-01-30:40%:特になし")

    actual_entries = @parser.parse_stream("taro", report_io)
    expected_entries = [
      {:name => "taro", :date => "2013-01-30", :read_ratio => 40, :comment => "特になし"},
    ]
    assert_equal(expected_entries, actual_entries.collect(&:to_hash))
  end

  def test_missing_colon
    report_io = StringIO.new(<<-REPORT)
2013-1-30:40%
2013-2-1:80%
2013-2-2:50%
  PHPのコードを久しぶりに書いた
  データ駆動を使ってテストがどんどん書き直されていた
REPORT

    actual_entries = @parser.parse_stream("taro", report_io)
    continues_comment = <<-COMMENT
PHPのコードを久しぶりに書いた
データ駆動を使ってテストがどんどん書き直されていた
COMMENT
    expected_entries = [
      {:name => "taro", :date => "2013-01-30", :read_ratio => 40, :comment => ""},
      {:name => "taro", :date => "2013-02-01", :read_ratio => 80, :comment => ""},
      {:name => "taro", :date => "2013-02-02", :read_ratio => 50, :comment => continues_comment.chomp},
    ]

    assert_equal(expected_entries, actual_entries.collect(&:to_hash))
  end

  def test_reverse_order
    report_io = StringIO.new(<<-REPORT)
2013-2-3:10%:
2013-2-2:50%:
  PHPのコードを久しぶりに書いた
  データ駆動を使ってテストがどんどん書き直されていた
2013-2-1:80%:typoが多かった
REPORT

    actual_entries = @parser.parse_stream("taro", report_io)
    continues_comment = "PHPのコードを久しぶりに書いた\n" +
                          "データ駆動を使ってテストがどんどん書き直されていた"
    expected_entries = [
      {:name => "taro", :date => "2013-02-03", :read_ratio => 10, :comment => ""},
      {:name => "taro", :date => "2013-02-02", :read_ratio => 50, :comment => continues_comment},
      {:name => "taro", :date => "2013-02-01", :read_ratio => 80, :comment => "typoが多かった"},
    ]
    assert_equal(expected_entries, actual_entries.collect(&:to_hash))
  end
end
