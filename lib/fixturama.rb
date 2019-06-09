require "erb"
require "factory_bot"
require "hashie/mash"
require "json"
require "rspec"
require "yaml"

module Fixturama
  require_relative "fixturama/config"
  require_relative "fixturama/utils"
  require_relative "fixturama/loader"
  require_relative "fixturama/stubs"
  require_relative "fixturama/seed"

  def self.start_ids_from(value)
    Config.start_ids_from(value)
  end

  def stub_fixture(path, **opts)
    items = load_fixture(path, **opts)
    raise "The fixture should contain an array" unless items.is_a?(Array)

    items.each { |item| fixturama_stubs.add(item) }
    fixturama_stubs.apply(self)
  end

  def seed_fixture(path, **opts)
    Array(load_fixture(path, **opts)).each { |item| Seed.call(item) }
  end

  def load_fixture(path, **opts)
    Loader.new(path, opts).call
  end

  def read_fixture(path, **opts)
    content  = File.read(path)
    hashie   = Hashie::Mash.new(opts)
    bindings = hashie.instance_eval { binding }

    ERB.new(content).result(bindings)
  end

  private

  def fixturama_stubs
    @fixturama_stubs ||= Stubs.new
  end
end
