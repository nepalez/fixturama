class Fixturama::Changes
  #
  # @private
  # Seed objects using the +FactoryBot+
  #
  class Seed < Base
    private

    def initialize(**options)
      @type   = type_from(options)
      @traits = traits_from(options)
      @params = params_from(options)
      @count  = count_from(options)
      create_object
    end

    def type_from(options)
      options[:type]&.to_sym&.tap { |value| return value }
      raise Fixturama::FixtureError.new("a factory", options)
    end

    def traits_from(options)
      Array(options[:traits]).map(&:to_sym)
    end

    def params_from(options)
      Hash(options[:params]).transform_keys(&:to_sym)
    end

    def count_from(options)
      options.fetch(:count, 1).to_i.tap { |val| return val if val.positive? }
      raise Fixturama::FixtureError.new("a valid number of objects", options)
    end

    def create_object
      FactoryBot.create_list(@type, @count, *@traits, **@params)
    end
  end
end
