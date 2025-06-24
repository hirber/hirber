# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require "rubygems" unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/hirb/version"

Gem::Specification.new do |s|
  s.name        = "hirber"
  s.version     = Hirb::VERSION

  s.authors     = ["Gabriel Horner", "Marz Drel"]
  s.email       = "marzdrel@dotpro.org"
  s.homepage    = "https://github.com/hirber/hirber"

  s.summary     = <<~TXT.gsub(/[[:space:]]+/, " ").strip
    A mini view framework for console/irb that's easy to use, even while under
    its influence.
  TXT

  s.description = <<~TXT.gsub(/[[:space:]]+/, " ").strip
    Hirb provides a mini view framework for console applications and uses
    it to improve ripl(irb)'s default inspect output. Given an object or
    array of objects, hirb renders a view based on the object's class and/or
    ancestry. Hirb offers reusable views in the form of helper classes. The
    two main helpers, Hirb::Helpers::Table and Hirb::Helpers::Tree,
    provide several options for generating ascii tables and trees. Using
    Hirb::Helpers::AutoTable, hirb has useful default views for at least ten
    popular database gems i.e. Rails' ActiveRecord::Base. Other than views,
    hirb offers a smart pager and a console menu. The smart pager only pages
    when the output exceeds the current screen size. The menu is used in
    conjunction with tables to offer two dimensional menus.
  TXT

  s.required_rubygems_version = ">= 1.3.5"

  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "standardrb"
  s.add_development_dependency "rspec", ">= 3.9"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "bacon", "~> 1.1"
  s.add_development_dependency "mocha", "~> 0.12.1"
  s.add_development_dependency "mocha-on-bacon", "~> 0.2.1"
  s.add_development_dependency "bacon-bits", "~> 0.1"

  s.files =
    Dir.glob %w[
      {lib,test,spec}/**/*.rb
      bin/*
      [A-Z]*.{txt,rdoc,md}
      ext/**/*.{rb,c}
      Rakefile
      .gemspec
      .travis.yml
    ]

  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = "MIT"
end
