module Fixturama
  #
  # Collection of stubbed calls
  #
  class Stubs
    require_relative "stubs/chain"
    require_relative "stubs/const"

    #
    # Register new action and apply the corresponding stub
    #
    # @params [Hash<#to_s, _>] options
    # @return [self] itself
    #
    def add(options)
      options = symbolize(options)
      find_or_create_stub!(options)&.update!(options)
      self
    end

    #
    # Applies the stub to RSpec example
    #
    def apply(example)
      @stubs.values.each { |stub| stub.apply!(example) }
    end

    private

    def initialize
      @stubs = {}
    end

    def find_or_create_stub!(options)
      stub = case stub_type(options)
             when :message_chain then Chain.new(options)
             when :constant      then Const.new(options)
             end

      @stubs[stub.key] ||= stub if stub
    end

    def stub_type(options)
      key = (TYPES.keys & options.keys).first
      return TYPES[key] if key

      raise ArgumentError, <<~MESSAGE
        Cannot figure out what to stub from #{options}.
        You should define either a class and a message chain, or some const.
      MESSAGE
    end

    # Matches keys to the type of the stub
    TYPES = {
      arguments: :message_chain,
      actions: :message_chain,
      chain: :message_chain,
      class: :message_chain,
      const: :constant,
      object: :message_chain,
      value: :constant,
    }.freeze

    def symbolize(options)
      Hash(options).transform_keys { |key| key.to_s.to_sym }
    end
  end
end
