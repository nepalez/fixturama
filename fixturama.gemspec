# frozen_string_literal: true

require_relative "lib/fixturama/version"

Gem::Specification.new do |gem|
  gem.name     = "fixturama"
  gem.version  = Fixturama::VERSION
  gem.summary  = "A set of helpers to prettify specs with fixtures"
  gem.description = <<~DESC
    Use fixtures to extract verbosity from RSpec specifications:
    - load data,
    - stub classes, modules and constants,
    - seed the database via FactoryBot.
  DESC
  gem.authors = ["Andrew Kozin (nepalez)"]

  gem.license  = "MIT"
  gem.email    = "andrew.kozin@gmail.com"
  gem.homepage = "https://github.com/nepalez/fixturama"
  gem.metadata = {
    "bug_tracker_uri" => "https://github.com/nepalez/fixturama/issues",
    "changelog_uri" =>
      "https://github.com/nepalez/fixturama/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydocs.info/gems/fixturama",
    "homepage_uri" => gem.homepage,
    "source_code_uri" => "https://github.com/nepalez/fixturama"
  }

  gem.files = Dir["lib/**/*"]
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]
  gem.rdoc_options += [
    "--title", "Fixturama - fixtures on steroids",
    "--main", "README.md",
    "--line-numbers",
    "--inline-source",
    "--quiet"
  ]

  gem.required_ruby_version = ">= 2.2"

  gem.add_runtime_dependency "factory_bot", "~> 4.0"
  gem.add_runtime_dependency "rspec", "~> 3.0"
  gem.add_runtime_dependency "hashie", "> 3", "< 5"
  gem.add_runtime_dependency "webmock", "~> 3.0"

  gem.add_development_dependency "rake", "~> 13.0"
  gem.add_development_dependency "rspec-its", "~> 1.3"
  gem.add_development_dependency "rubocop", "~> 0.80"
  gem.add_development_dependency "rubocop-packaging"
end
