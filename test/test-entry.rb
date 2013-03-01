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

require "commit-comment-tools/entry"

class EntryTest < Test::Unit::TestCase
  def test_name
    expected_name = "yamada"
    entry = generate_entry(:name => expected_name)
    assert_equal(expected_name, entry.name)
  end

  data(:with_zero_padding    => "2013-02-05",
       :without_zero_padding => "2013-2-5")
  def test_date(date)
    entry = generate_entry(:date => date)
    expected_date = Date.parse("2013-02-05").strftime("%Y-%m-%d")
    assert_equal(expected_date, entry.date)
  end

  def test_read_ratio
    entry = generate_entry(:read_ratio => "10")
    assert_equal(10, entry.read_ratio)
  end

  data(:one_line           => "typoのコミットが多かった。",
       :continues_line     => "typoのコミットが多かった。\ngit-rebaseって何？",
       :nonexistent        => "")
  def test_comment(comment)
    entry = generate_entry(:comment => comment)
    assert_equal(comment, entry.comment)
  end

  class InvalidEntryTest < self
    data(:no_separate    => "20130205",
         :slash_separate => "2013/02/05",
         :nonexistent    => "")
    def test_date(invalid_date)
      assert_raise(CommitCommentTools::Entry::InvalidEntryError) do
        generate_entry(:date => invalid_date)
      end
    end

    data(:decimal_number => "10.5",
         :no_number      => "NoNumber",
         :nonexistent    => "")
    def test_read_ratio(invalid_read_ratio)
      assert_raise(CommitCommentTools::Entry::InvalidEntryError) do
        generate_entry(:read_ratio => invalid_read_ratio)
      end
    end
  end

  private
  def generate_entry(options={})
    name       = options[:name]       || "yamada"
    date       = options[:date]       || "2013-02-20"
    read_ratio = options[:read_ratio] || "10"
    comment    = options[:comment]    || "あんまり読めなかった。"

    entry_chunk = "#{date}:#{read_ratio}%:#{comment}"
    CommitCommentTools::Entry.new(name, entry_chunk)
  end
end
