require "erb"
require "factory_bot"
require "hashie/mash"
require "json"
require "rspec"
require "yaml"

module Fixturama
  require_relative "fixturama/config"
  require_relative "fixturama/utils"
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
    basename = Pathname.new(path).basename.to_s

    read_fixture(path, **opts).tap do |content|
      return YAML.load(content)  if basename[YAML]
      return JSON.parse(content) if basename[JSON]
    end
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

  # Matchers for YAML/YML/JSON in file extension like "data.yml.erb" etc.
  YAML = /.+\.ya?ml(\.|\z)/i.freeze
  JSON = /.+\.json(\.|\z)/i.freeze
end
