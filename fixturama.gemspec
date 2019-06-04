Gem::Specification.new do |gem|
  gem.name     = "fixturama"
  gem.version  = "0.0.5"
  gem.author   = "Andrew Kozin (nepalez)"
  gem.email    = "andrew.kozin@gmail.com"
  gem.homepage = "https://github.com/nepalez/fixturama"
  gem.summary  = "A set of helpers to prettify specs with fixtures"
  gem.license  = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]

  gem.required_ruby_version = ">= 2.2"

  gem.add_runtime_dependency "factory_bot", "~> 4.0"
  gem.add_runtime_dependency "rspec", "~> 3.0"
  gem.add_runtime_dependency "hashie", "~> 3.6"

  gem.add_development_dependency "rake", "~> 10"
  gem.add_development_dependency "rspec-its", "~> 1.2"
  gem.add_development_dependency "rubocop", "~> 0.49"
end
