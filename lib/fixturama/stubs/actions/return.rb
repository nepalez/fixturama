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
    @call = output.respond_to?(:dup) ? output.dup : output
  end
end
