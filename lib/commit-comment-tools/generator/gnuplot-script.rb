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

require "erb"

module CommitCommentTools
  module Generator
    class GnuplotScript
      def initialize(options={})
        @input_filename = options[:input_filename]
        @output_filename = options[:output_filename]
        @output_image_filename = options[:output_image_filename]
        @template = options[:template]
        @template_path = template_path(@template)
      end

      def generate
        prepare
        File.open(@output_filename, "w") do |file|
          erb = ERB.new(File.read(@template_path), nil, "-")
          erb.filename = File.basename(@template_path)
          file.puts erb.result(binding)
        end
      end

      private

      def template_path(template)
        source_dir = Pathname(__FILE__).parent.parent.parent.parent.expand_path
        source_dir + "templates" + "#{template}.gp.erb"
      end

      def prepare
        case @template
        when :pareto
          first_line = File.open(@input_filename, "r") {|file| file.gets.chomp }
          @line_titles, @stacked_titles = first_line.split(",")[1..-1].partition do |element|
            /stacked/ !~ element
          end
          @stacked_titles = @stacked_titles.map do |title|
            title.gsub(/\(stacked\)/, "")
          end
        when :average
          # Do nothing
        else
          raise "Must not happen. template:#{@template}"
        end
      end
    end
  end
end
