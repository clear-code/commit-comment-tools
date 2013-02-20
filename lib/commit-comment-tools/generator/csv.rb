require "csv"

module CommitCommentTools
  module Generator
    class CSV
      def initialize(normalized_reports, options={})
        @normalized_reports = normalized_reports
        @options = options
      end

      def run
        members = []
        daily_report = Hash.new {|h, k| h[k] = {}}
        @normalized_reports.each do |name, diary|
          members << name
          diary.each do |date, report|
            daily_report[date][name] = report[:read_ratio]
          end
        end
        sorted_members = members.sort
        csv_string = daily_report2csv(sorted_members, daily_report)
        # TODO write to file
        puts csv_string
      end

      private
      def daily_report2csv(members, daily_report)
        csv_string = ::CSV.generate do |csv|
          csv << ["DATE", *members]
          daily_report.sort_by {|date, _| date}.each do |date, record|
            row_values = daily_record2row(record, members)
            csv << [date, *row_values]
          end
        end
        csv_string
      end

      def daily_record2row(record, members)
        values = []
        members.each do |name|
          values << (record[name] || 0)
        end
        values
      end

    end
  end
end
