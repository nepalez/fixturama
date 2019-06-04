module Fixturama
  #
  # Definition for stubbing a constant
  #
  class Stubs::Const
    attr_reader :const, :value

    #
    # Human-readable representation of the chain
    # @return [String]
    #
    def to_s
      const.to_s
    end
    alias to_str to_s

    #
    # Overload the definition for the constant
    # @option [Object] value
    # @return [self]
    #
    def update!(value:, **)
      @value = value
      self
    end

    #
    # Apply the stub to RSpec example
    # @return [self]
    #
    def apply!(example)
      example.send(:stub_const, const, value)
      self
    end

    private

    def initialize(const:, **)
      @const = const.to_s
    end
  end
end
