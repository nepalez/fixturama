class Fixturama::Changes
  #
  # @private
  # Stub a chain of messages
  #
  class Chain < Base
    require_relative "chain/raise_action"
    require_relative "chain/return_action"
    require_relative "chain/actions"
    require_relative "chain/arguments"

    def key
      @key ||= ["chain", @receiver.name, *@messages].join(".")
    end

    def merge(other)
      return self unless other.class == self.class && other.key == key

      tap { @arguments = (other.arguments | arguments).sort_by(&:order) }
    end

    def call(example)
      call_action = example.send(:receive_message_chain, *@messages) do |*real|
        action = arguments.find { |expected| expected.match?(*real) }
        action ? action.call : raise("Unexpected arguments: #{real}")
      end

      example.send(:allow, @receiver).to call_action
    end

    protected

    attr_reader :arguments

    private

    def initialize(**options)
      @receiver  = receiver_from(options)
      @messages  = messages_from(options)
      @arguments = [Arguments.new(options)]
    end

    def receiver_from(options)
      case options.slice(:class, :object).keys
      when %i[class]  then Kernel.const_get(options[:class])
      when %i[object] then Object.send(:eval, options[:object])
      else raise
      end
    rescue StandardError => err
      raise Fixturama::FixtureError.new("a stabbed object", options, err)
    end

    def messages_from(options)
      case value = options[:chain]
      when Array  then value.map(&:to_sym)
      when String then [value.to_sym]
      when Symbol then value
      else raise
      end
    rescue StandardError => err
      raise Fixturama::FixtureError.new("a messages chain", options, err)
    end
  end
end
