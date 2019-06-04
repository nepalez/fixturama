module Fixturama
  #
  # Collection of arguments for a stub with a list of actions to be called
  #
  class Stubs::Chain::Arguments
    attr_reader :chain, :arguments

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
      @arguments.zip(actual_arguments).map { |(x, y)| x == y }.reduce(true, :&)
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
      list.fetch(counter) { list.last }.call.tap { @counter += 1 }
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
    def initialize(chain, list)
      @chain     = chain
      @arguments = Utils.array(list)
    end

    def counter
      @counter ||= 0
    end

    def list
      @list ||= []
    end
  end
end
