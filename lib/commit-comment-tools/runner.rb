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

require "pathname"
require "optparse"

require "commit-comment-tools/version"

libdir = Pathname.new(__FILE__).realpath.dirname.parent.cleanpath
subcommands_dir = libdir + "commit-comment-tools/subcommands"
Dir.glob(File.join(subcommands_dir.to_s, "*.rb")) do |entry|
  require "commit-comment-tools/subcommands/#{File.basename(entry, ".rb")}"
end

module CommitCommentTools
  class Runner
    def run(argv)
      prepare
      _run(argv)
    rescue Errno::EPIPE
      exit(true)
    end

    def prepare
      @global_options = {}
      @parser = OptionParser.new
      @parser.version = CommitCommentTools::VERSION
      @parser.banner = <<-BANNER
Usage: #{File.basename($0)} [global options] <subcommand> [options] [args]

Subcommands:
    load-commits     Load commit information into database.
    analyze-commits  Analyze commit information in database.
    analyze-reports  Analyze daily reports.
    fetch-mails      Fetch commit mails.
    count-mails      Count commit mails.

Global Opions:
      BANNER

      @parser.on('--help', 'Prints this message and quit.') do
        $stderr.puts @parser.help
        exit(true)
      end

      @subcommands = {
        "load-commits"    => CommitCommentTools::Subcommands::LoadCommitsCommand.new,
        "analyze-commits" => CommitCommentTools::Subcommands::AnalyzeCommitsCommand.new,
        "analyze-reports" => CommitCommentTools::Subcommands::AnalyzeReportsCommand.new,
        "fetch-mails"     => CommitCommentTools::Subcommands::FetchMailsCommand.new,
        "count-mails"     => CommitCommentTools::Subcommands::CountMailsCommand.new,
      }
    end

    def _run(argv)
      begin
        @parser.order!(argv)
        if argv.empty?
          $stderr.puts "No subcommand given"
          $stderr.puts @parser.help
          exit(false)
        end
        command_name = argv.shift
        command = @subcommands[command_name] or error "No such subcommand: #{command_name}"
      rescue OptionParser::ParseError => ex
        $stderr.puts ex.message
        $stderr.puts @parser.help
        exit(false)
      end
      begin
        command.parse(argv)
      rescue OptionParser::ParseError => ex
        $stderr.puts ex.message
        $stderr.puts command.help
        exit(false)
      end
      command.exec(@global_options, argv)
    end

    def error(message)
      $stderr.puts "#{File.basename($0, '.*')}: error: #{message}"
      exit(false)
    end
  end
end
