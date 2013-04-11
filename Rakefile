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

require "pathname"
require "yard"
require "packnga"
require "rubygems"
require "bundler/gem_helper"

base_dir = File.dirname(__FILE__)
helper = Bundler::GemHelper.new(base_dir)
def helper.version_tag
  version
end

helper.install
spec = helper.gemspec
version = spec.version

Packnga::DocumentTask.new(spec) do |task|
  task.original_language = "en"
end

Packnga::ReleaseTask.new(spec) do |task|
end

desc "Run tests."
task :test do
  ruby("test/run-test.rb")
end

task :default => :test
