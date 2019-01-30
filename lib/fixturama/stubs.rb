module Fixturama
  class Stubs
    require_relative "stubs/actions"
    require_relative "stubs/raise"
    require_relative "stubs/return"

    def add(options)
      options = Utils.symbolize_hash(options)
      klass, chain, actions = options.values_at(:class, :chain, :actions)

      klass = Utils.constantize(klass)
      chain = Utils.symbolize_array(chain)
      actions ||= { return: nil }

      Array(actions).each do |action|
        collection[[klass, chain]] ||= Actions.new
        collection[[klass, chain]].add action
      end

      self
    end

    def apply(example)
      collection.each do |(klass, chain), actions|
        example.send(:allow, klass).to example.receive_message_chain(chain) do
          actions.call_next
        end
      end
    end

    private

    def collection
      @collection ||= {}
    end
  end
end
