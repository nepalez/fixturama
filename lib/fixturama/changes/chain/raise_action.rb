class Fixturama::Changes::Chain
  #
  # @private
  # Raise a specified exception as a result of stubbing
  #
  class RaiseAction
    attr_reader :repeat

    def call
      raise @error
    end

    private

    def initialize(**options)
      @error  = error_from options
      @repeat = repeat_from options
    rescue StandardError => err
      raise Fixturama::FixtureError.new("an exception class", options, err)
    end

    def error_from(options)
      klass  = klass_from(options)
      params = options[:arguments]
      params.is_a?(Array) ? klass.new(*params) : klass
    end

    def klass_from(options)
      klass = case value = options[:raise]
              when NilClass, TrueClass, "true" then StandardError
              when Class then value
      else Kernel.const_get(value)
      end

      klass < Exception ? klass : raise("#{klass} is not an exception")
    end

    def repeat_from(options)
      options.fetch(:repeat, 1).to_i.tap { |val| return val if val.positive? }
      raise Fixturama::FixtureError.new("a number of repeats", options)
    end
  end
end
