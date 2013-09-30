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

require "optparse"
require "pathname"

require "commit-comment-tools/generator/gnuplot-script"

module CommitCommentTools
  module Subcommands
    class GnuplotScriptCommand < Subcommand
      def initialize
        super
        @input_filename = nil
        @output_filename = nil
        @output_image_filename = nil
        @template = :pareto
        prepare
      end

      def prepare
        @parser.banner = <<-BANNER
Usage: #{$0} [options]
  e.g: #{$0} --input-file=xxx.csv --output-file=xxx.png --template=pareto
        BANNER

        @parser.separator("")
        @parser.separator("Options:")

        @parser.on("-i", "--input-filename=FILENAME", String, "Input filename.") do |path|
          @input_filename = Pathname(path).expand_path.to_s
        end

        @parser.on("-o", "--output-filename=FILENAME", String, "Output filename.") do |path|
          @output_filename = Pathname(path).expand_path.to_s
        end

        @parser.on("-O", "--output-image-filename=IMAGE", String, "Output image filename.") do |path|
          @output_image_filename = Pathname(path).expand_path.to_s
        end

        available_templates = [:pareto, :average]
        @parser.on("-T", "--template=TEMPLATE", available_templates,
                   "Template",
                   "available templates: [#{available_templates.join(", ")}]",
                   "[#{@template}]") do |template|
          @template = template
        end
      end

      def parse(argv)
        super
        option_error("Must specify --input-filename") if @input_filename.nil?
        option_error("Must specify --output-filename") if @output_filename.nil?
        option_error("Must specify --output-image-filename") if @output_image_filename.nil?
      end

      def exec(global_options, argv)
        options = {
          :input_filename        => @input_filename,
          :output_filename       => @output_filename,
          :output_image_filename => @output_image_filename,
          :template              => @template
        }
        generator = Generator::GnuplotScript.new(options)
        generator.generate
      end
    end
  end
end

