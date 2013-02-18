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
  class ReportNormlizer
    class << self
      def normalize(parsed_reports)
        new.normalize(parsed_reports)
      end
    end

    def initialize
      @person_reports = {}
    end

    def normalize(parsed_reports)
      parsed_reports.each do |person, daily_report|
        normalize_daily_report(person, daily_report)
      end
      @person_reports
    end

    def normalize_daily_report(person, daily_report)
      @person_reports[person] = {}

      daily_report.each do |date, report|
        normalized_date = normalize_date(date)
        @person_reports[person][normalized_date] = normalize_report(report)
      end
      @person_reports
    end

    def normalize_date(date)
      Date.parse(date).strftime("%Y-%m-%d")
    end

    def normalize_report(report)
      report[:read_ratio] = report[:read_ratio].to_i
      report
    end
  end
end
