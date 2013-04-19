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

require "commit-comment-tools/repository-loader"

module CommitCommentTools::Subcommands
  class LoadCommitsCommand < CommitCommentTools::Subcommand
    def initialize
      super
      @repository_path = nil
      @branch_name = nil
      @db_path = nil
      @parser.banner = <<-BANNER
Usage: #{$0} [options]
  e.g: #{$0} -d ./commits.db -r ./sample_project -b master
       #{$0} -d ./commits.db -r ./sample_project -b /pattern/
  BANNER

      @parser.on("-r=PATH", "--repository=PATH", String, "Git repository path.") do |path|
        @repository_path = Pathname(path).realpath.to_s
      end

      @parser.on("-b=NAME", "--branch=NAME", String,
                 "Load commits in matching branch NAME (patterns may be used).") do |name|
        pattern = name.slice(%r!\A/(.*)/\z!, 1)
        if pattern
          @branch_name = Regexp.new(pattern)
        else
          @branch_name = name
        end
      end

      @parser.on("-d=PATH", "--database=PATH", String, "Database path.") do |path|
        @db_path = Pathname(path).expand_path.to_s
      end
    end

    def exec(global_options, argv)
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: @db_path)
      loader = CommitCommentTools::RepositoryLoader.new(@repository_path, @branch_name)
      loader.load_commits
    end
  end
end