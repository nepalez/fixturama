module Fixturama
  class Stubs
    class Return
      attr_reader :call

      private

      def initialize(output)
        @call = Utils.clone(output)
      end
    end
  end
end
