class Fixturama::Stubs::Actions::Return
  attr_reader :stub, :call

  #
  # Human-readable representation of the expectation
  # @return [String]
  #
  def to_s
    "#{@stub} # => #{call}"
  end

  private

  def initialize(stub, output)
    @stub = stub
    @call = \
      begin # in ruby 2.3.0 Fixnum#dup is defined, but raises TypeError
        output.respond_to?(:dup) ? output.dup : output
      rescue TypeError
        output
      end
  end
end
