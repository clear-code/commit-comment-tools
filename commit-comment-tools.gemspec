# -*- coding: utf-8; mode: ruby -*-
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

clean_white_space = lambda do |entry|
  entry.gsub(/(\A\n+|\n+\z)/, "") + "\n"
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
require "commit-comment-tools/version"

version = CommitCommentTools::VERSION.dup

readme = File.read("README.md")
readme.force_encoding("UTF-8") if readme.respond_to?(:force_encoding)
entries = readme.split(/^## (.+)$/)
authors = clean_white_space.call(entries[entries.index("Authors") + 1])
author_names = []
author_mails = []
authors.each_line do |author|
  if /^\* (.+): `<(.+)>`/ =~ author
    author_names << $1
    author_mails << $2
  end
end
summary = clean_white_space.call(entries[entries.index("Description") + 1])

Gem::Specification.new do |spec|
  spec.name = "commit-comment-tools"
  spec.version = version
  spec.authors = author_names
  spec.email = author_mails
  spec.summary = summary
  spec.license = "GPLv3 or later"
  spec.files = ["README.md"]
  spec.files += ["Rakefile", "Gemfile", "commit-comment-tools.gemspec"]
  spec.files += [".yardopts"]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("templates/*.gp.erb")
  spec.files += Dir.glob("doc/text/*")
  spec.test_files = Dir.glob("test/**/*.rb")
  Dir.chdir("bin") do
    spec.executables = Dir.glob("*")
  end

  spec.add_runtime_dependency("activerecord")
  spec.add_runtime_dependency("sqlite3")
  spec.add_runtime_dependency("grit")
  spec.add_runtime_dependency("gnuplot")
  spec.add_development_dependency("test-unit")
  spec.add_development_dependency("test-unit-notify")
  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("yard")
  spec.add_development_dependency("packnga")
  spec.add_development_dependency("redcarpet")
end
