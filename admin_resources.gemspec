# frozen_string_literal: true

require_relative "lib/admin_resources/version"

Gem::Specification.new do |spec|
  spec.name = "admin_resources"
  spec.version = AdminResources::VERSION
  spec.authors = ["mark rosenberg"]
  spec.email = ["mark@does.work"]

  spec.summary = "Mountable Rails engine that auto-generates admin CRUD UI for registered models."
  spec.description = "Mount AdminResources::Engine in your Rails app, configure which models to expose, and get a full admin dashboard with zero boilerplate."
  spec.homepage = "https://github.com/markdoeswork/admin_resources"
  spec.required_ruby_version = ">= 3.0.0"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "devise", ">= 4.0"
end
