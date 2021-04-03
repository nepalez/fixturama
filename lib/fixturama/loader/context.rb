class Fixturama::Loader
  #
  # @private
  # The context bound to some fixture
  #
  class Context
    def object(value)
      Marshal.dump(value).dump
    end

    # Get value by key
    # @param  [#to_s] key
    # @return [Object]
    def [](key)
      @values.send(key).instance_variable_get(:@value)
    end

    private

    def initialize(example, values)
      @example = example
      @values = \
        Hash(values).each_with_object(Hashie::Mash.new) do |(key, val), obj|
          obj[key] = Value.new(key, val)
        end
    end

    def respond_to_missing?(name, *)
      @values.key?(name) || @example.respond_to?(name) || super
    end

    def method_missing(name, *args, &block)
      return @values[name] if @values.key?(name)
      return super unless @example.respond_to?(name)

      @example.send(name, *args, &block)
    end
  end
end
