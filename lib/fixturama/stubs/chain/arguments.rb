module Fixturama
  #
  # Collection of arguments for a stub with a list of actions to be called
  #
  class Stubs::Chain::Arguments
    attr_reader :chain, :arguments, :within_transaction

    #
    # Register new action for these set of arguments
    # @option [#to_i] :repeat (1)
    #   How much the action should be repeated during the consecutive calls
    # @return [self] itself
    #
    def add!(*actions)
      actions.each do |settings|
        settings = Utils.symbolize_hash(settings)
        repeat   = [0, settings.fetch(:repeat, 1).to_i].max
        repeat.times { list << Stubs::Chain::Actions.build(self, settings) }
      end

      self
    end

    #
    # Whether the current stub is applicable to actual arguments
    # @param  [Array<Object>] actual_arguments
    # @return [Boolean]
    #
    def applicable_to?(actual_arguments)
      last_index = actual_arguments.count
      @arguments.zip(actual_arguments)
                .each.with_index(1)
                .reduce(true) do |obj, ((expected, actual), index)|
                  obj && (
                    expected == actual ||
                    index == last_index &&
                    Fixturama::Utils.matched_hash_args?(actual, expected)
                  )
                end
    end

    #
    # Reset the counter of calls
    # @return [self] itself
    #
    def reset!
      @counter = 0
      self
    end

    #
    # Calls the next action for these set of agruments
    # @return [Object]
    # @raise  [StandardError]
    #
    def call_next!
      action = list.fetch(counter) { list.last }
      isolate! unless within_transaction
      action.call
    ensure
      @counter += 1
    end

    #
    # Human-readable representation of arguments
    # @return [String]
    #
    def to_s
      args = [*arguments.map(&:to_s), "*"].join(", ")
      "#{chain}(#{args})"
    end

    private

    # @param [Fixturama::Stubs::Chain] chain Back reference
    # @param [Array<Object>] list Definition of arguments
    def initialize(chain, within_transaction, list)
      @chain = chain
      @within_transaction = within_transaction || (require("isolator") || false)
      @arguments = Utils.array(list)
    end

    def counter
      @counter ||= 0
    end

    def list
      @list ||= []
    end

    def isolate!
      return unless ::Isolator.within_transaction?

      raise ::Isolator::UnsafeOperationError, <<~MESSAGE
        You're trying to call #{self} inside db transaction
      MESSAGE
    end
  end
end
