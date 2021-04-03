begin
  require "pry"
rescue LoadError
  nil
end

require "bundler/setup"
require "fixturama/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    module Test; end
    example.run
    Object.send(:remove_const, :Test)
  end
end
