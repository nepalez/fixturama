module Fixturama
  #
  # Collection of stubbed calls
  #
  class Stubs
    require_relative "stubs/actions"
    require_relative "stubs/arguments"
    require_relative "stubs/chain"

    #
    # Register new action and apply the corresponding stub
    #
    # @option [#to_s]        :class Class to stub
    # @option [Array<#to_s>] :chain Methods chain for stubbing
    # @option (see Fixturama::Stubs::Method#add)
    # @return [self] itself
    #
    def add(options)
      tap do
        options = Utils.symbolize_hash(options)

        options.select { |key| %i[class chain].include?(key) }.tap do |anchors|
          chains[anchors] ||= Chain.new(anchors)
          chains[anchors].add(options)
        end
      end
    end

    #
    # Applies the stub to RSpec example
    #
    def apply(example)
      chains.values.each do |chain|
        chain.reset!
        call_action = \
          example.send(:receive_message_chain, *chain.messages) do |*args|
            chain.call! args
          end
        example.send(:allow, chain.receiver).to call_action
      end
    end

    private

    def chains
      @chains ||= {}
    end
  end
end
