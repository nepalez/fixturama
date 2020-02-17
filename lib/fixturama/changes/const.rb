class Fixturama::Changes
  #
  # @private
  # Stub a constant
  #
  class Const < Base
    def key
      name
    end

    def call(example)
      example.send(:stub_const, name, value)
      self
    end

    private

    def initialize(**options)
      @options = options
    end

    def name
      @options[:const]
    end

    def value
      @options[:value]
    end
  end
end
