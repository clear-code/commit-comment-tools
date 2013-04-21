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

require "gnuplot"

module CommitCommentTools
  module Generator
    class Graph
      def initialize(entries, options={})
        @entries = entries
        @options = options
        @output_filename = options[:output_filename]
      end

      def generate
        date_list = @entries.collect(&:date).sort.uniq
        members = @entries.collect(&:name).sort.uniq
        colors = %w[red green blue light-blue orange brown dark-salmon]

        #Gnuplot.open do |gp|
        IO.popen("/usr/bin/gnuplot", "w+") do |io|
          io.puts %Q!set terminal png!
          io.puts %Q!set output "#{@output_filename}"!
          io.puts %Q!set title "Read ratio"!
          io.puts %Q!set ylabel "read ratio"!
          io.puts %Q!set xlabel "date"!
          io.puts %Q!set xdata time!
          io.puts %Q!set timefmt "%Y-%m-%d"!
          io.puts %Q!set format x "%m/%d"!
          io.puts %Q!set xrange ["#{date_list.first}":"#{date_list.last}"]!

          commands = []
          p [members.size, members]
          members.each_with_index do |member, index|
            commands << " 'data/daily.csv' using 1:#{index + 2} with linespoints pointtype 7"
          end
          io.puts "plot #{commands.join(",")};"
          sleep 0.1
          date_list.each do |date|
            target_entries = extract_target_entries(date, members)
            daily_read_ratios = target_entries.collect do |entry|
              entry ? entry.read_ratio : 0
            end
            #io.puts "#{date}\t#{daily_read_ratios.join("\t")}"
          end
          #io.puts "e"
          # members.each_with_index do |member, index|
          #   #sleep 0.1
          #   date_list.each_with_index do |date, index|
          #     target_entry = @entries.detect do |entry|
          #       entry.date == date and entry.name == member
          #     end
          #     read_ratio = target_entry ? target_entry.read_ratio : 0
          #     io.puts "#{date}\t#{read_ratio}.0"
          #   end
          # io.puts "e"
          # end
        end
      end

      private

      def extract_target_entries(date, members)
        entries = @entries.select do |entry|
          entry.date == date
        end
        target_entries = []
        members.each do |name|
          target_entries << entries.detect do |entry|
            entry.name == name
          end
        end
        target_entries
      end
    end
  end
end
