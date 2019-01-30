module Fixturama
  class Stubs
    class Actions
      def add(opts)
        queue.push build(opts)
        self
      end

      def call_next
        queue.pop.tap { |item| queue.push(item.dup) if queue.empty? }.call
      end

      private

      def build(opts)
        opts = Utils.symbolize_hash(opts)
        return Raise.new opts[:raise] if opts.key?(:raise)

        Return.new opts[:return]
      end

      def queue
        @queue ||= Queue.new
      end
    end
  end
end
