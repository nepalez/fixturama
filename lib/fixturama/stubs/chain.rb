module Fixturama
  #
  # Stubbed chain of messages
  #
  class Stubs::Chain
    require_relative "chain/actions"
    require_relative "chain/arguments"

    attr_reader :receiver, :messages

    #
    # Human-readable representation of the chain
    # @return [String]
    #
    def to_s
      "#{receiver}.#{messages.join(".")}"
    end
    alias to_str to_s

    #
    # Register new action for some arguments
    #
    # @option [Array<#to_s>, #to_s] :arguments The specific arguments
    # @option (see Fixturama::Stubs::Arguments#add_action)
    # @return [self]
    #
    def update!(actions:, arguments: nil, **)
      Utils.array(arguments).tap do |args|
        stub = find_by(args)
        unless stub
          stub = Stubs::Chain::Arguments.new(self, args)
          stubs << stub
        end
        stub.add!(*actions)
        stubs.sort_by! { |stub| -stub.arguments.count }
      end

      self
    end

    #
    # Apply the stub to RSpec example
    #
    def apply!(example)
      reset!

      call_action = example.send(:receive_message_chain, *messages) do |*args|
        call! args
      end

      example.send(:allow, receiver).to call_action
    end

    private

    def initialize(**options)
      @receiver = Utils.constantize options[:class]
      @messages = Utils.symbolize_array options[:chain]
      return if messages.any?

      raise SyntaxError, <<~MESSAGE.squish
        Indefined message chain for stubbing #{receiver}.
        Use option `chain` to define it.
      MESSAGE
    end

    def stubs
      @stubs ||= []
    end

    def find_by(arguments)
      stubs.find { |stub| stub.arguments == arguments }
    end

    def reset!
      tap { stubs.each(&:reset!) }
    end

    def call!(actual_arguments)
      stub = stubs.find { |item| item.applicable_to?(actual_arguments) }
      raise "Unexpected arguments #{actual_arguments}" unless stub

      stub.call_next!
    end
  end
end
