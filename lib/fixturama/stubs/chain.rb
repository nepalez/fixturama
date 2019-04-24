module Fixturama
  #
  # Stubbed chain of messages
  #
  class Stubs::Chain
    attr_reader :receiver, :messages

    #
    # Register new action for some arguments
    #
    # @option [Array<#to_s>, #to_s] :arguments The specific arguments
    # @option (see Fixturama::Stubs::Arguments#add_action)
    # @return [self]
    #
    def add(actions:, arguments: nil, **)
      Utils.array(arguments).tap do |args|
        stub = find_by(args)
        unless stub
          stub = Stubs::Arguments.new(self, args)
          stubs << stub
        end
        stub.add!(*actions)
        stubs.sort_by! { |stub| -stub.arguments.count }
      end

      self
    end

    #
    # Resets all counters
    # @return [self] itself
    #
    def reset!
      tap { stubs.each(&:reset!) }
    end

    #
    # Executes the corresponding action
    # @return [Object]
    # @raise  [StandardError]
    #
    def call!(actual_arguments)
      stub = stubs.find { |item| item.applicable_to?(actual_arguments) }
      raise "Unexpected arguments #{actual_arguments}" unless stub

      stub.call_next!
    end

    #
    # Human-readable representation of the chain
    # @return [String]
    #
    def to_s
      "#{receiver}.#{messages.join(".")}"
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
  end
end
