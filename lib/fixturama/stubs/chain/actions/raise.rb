class Fixturama::Stubs::Chain::Actions::Raise
  def call
    raise @exception
  end

  #
  # Human-readable representation of the expectation
  # @return [String]
  #
  def to_s
    "#{@stub} # raise #{@exception}"
  end

  private

  def initialize(stub, name)
    @stub = stub
    name = name.to_s
    @exception = name == "true" ? StandardError : Kernel.const_get(name)
  end
end
