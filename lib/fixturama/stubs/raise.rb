module Fixturama
  class Stubs
    class Raise
      def call
        raise @exception
      end

      private

      def initialize(exception)
        @exception = Utils.constantize(exception || StandardError)
      end
    end
  end
end
