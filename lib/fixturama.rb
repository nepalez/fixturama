require "erb"
require "factory_bot"
require "hashie/mash"
require "json"
require "rspec"
require "webmock/rspec"
require "yaml"

#
# A set of helpers to prettify specs with fixtures
#
module Fixturama
  require_relative "fixturama/fixture_error"
  require_relative "fixturama/config"
  require_relative "fixturama/loader"
  require_relative "fixturama/changes"

  # Set the initial value for database-generated IDs
  # @param [#to_i] value
  # @return [Fixturama]
  def self.start_ids_from(value)
    Config.start_ids_from(value)
    self
  end

  # @!method read_fixture(path, options)
  # Read the text content of the fixture
  # @param [#to_s] path The path to the fixture file
  # @param [Hash<Symbol, _>] options
  #   The list of options to be accessible in the fixture
  # @return [String]
  def read_fixture(path, **options)
    content  = File.read(path)
    hashie   = Hashie::Mash.new(options)
    bindings = hashie.instance_eval { binding }

    ERB.new(content).result(bindings)
  end

  # @!method load_fixture(path, options)
  # Load data from a fixture
  # @param (see #read_fixture)
  # @return [Object]
  def load_fixture(path, **options)
    Loader.new(self, path, options).call
  end

  # @!method call_fixture(path, options)
  # Stub different objects and seed the database from a fixture
  # @param (see #read_fixture)
  # @return [RSpec::Core::Example] the current example
  def call_fixture(path, **options)
    items = Array load_fixture(path, **options)
    items.each { |item| changes.add(item) }
    tap { changes.call(self) }
  rescue FixtureError => err
    raise err.with_file(path)
  end

  # @!method seed_fixture(path, options)
  # The alias for the +call_fixture+
  # @param (see #call_fixture)
  # @return (see #call_fixture)
  alias seed_fixture call_fixture

  # @!method stub_fixture(path, options)
  # The alias for the +call_fixture+
  # @param (see #call_fixture)
  # @return (see #call_fixture)
  alias stub_fixture call_fixture

  private

  def changes
    @changes ||= Changes.new
  end
end
