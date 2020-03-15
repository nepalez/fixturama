module Fixturama
  #
  # @private
  # Registry of changes (stubs and seeds)
  #
  class Changes
    require_relative "changes/base"
    require_relative "changes/chain"
    require_relative "changes/const"
    require_relative "changes/env"
    require_relative "changes/request"
    require_relative "changes/seed"

    # Match option keys to the type of an item
    TYPES = {
      actions: Chain,
      arguments: Chain,
      basic_auth: Request,
      body: Request,
      chain: Chain,
      class: Chain,
      const: Const,
      count: Seed,
      env: Env,
      headers: Request,
      http_method: Request,
      object: Chain,
      params: Seed,
      query: Request,
      response: Request,
      responses: Request,
      traits: Seed,
      type: Seed,
      uri: Request,
      url: Request,
    }.freeze

    # Adds new change to the registry
    # @param [Hash] options
    # @return [Fixturama::Changes]
    # @raise [Fixturama::FixtureError] if the options cannot be processed
    def add(options)
      options = Hash(options).transform_keys(&:to_sym)
      types = options.keys.map { |key| TYPES[key] }.compact.uniq
      raise "Wrong count" unless types.count == 1

      @changes << types.first.new(options)
      self
    rescue FixtureError => err
      raise err
    rescue StandardError => err
      raise FixtureError.new("an operation", options, err)
    end

    # Apply all registered changes to the RSpec example
    # @param [RSpec::Core::Example] example
    # @return [self]
    def call(example)
      @changes
        .group_by(&:key)
        .values
        .map { |changes| changes.reduce :merge }
        .each { |change| change.call(example) }
    end

    private

    def initialize
      @changes = []
    end
  end
end
