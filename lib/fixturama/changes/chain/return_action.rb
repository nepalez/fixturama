class Fixturama::Changes::Chain
  #
  # @private
  # Return a specified value as a result of stubbing
  #
  class ReturnAction
    attr_reader :repeat

    def call
      @value
    end

    private

    def initialize(**options)
      @value  = value_from(options)
      @repeat = repeat_from(options)
    end

    def value_from(options)
      value = options[:return]
      value.respond_to?(:dup) ? value.dup : value
    rescue TypeError
      # in the Ruby 2.3.0 Fixnum#dup is defined, but raises TypeError
      value
    end

    def repeat_from(options)
      options.fetch(:repeat, 1).to_i.tap { |val| return val if val.positive? }
      raise Fixturama::FixtureError.new("a number of repeats", options)
    end
  end
end
