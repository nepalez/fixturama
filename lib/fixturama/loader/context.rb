class Fixturama::Loader
  #
  # The context of some fixture
  #
  class Context
    # Get value by key
    # @param  [#to_s] key
    # @return [Object]
    def [](key)
      @values.send(key).instance_variable_get(:@value)
    end

    private

    def initialize(values)
      @values = \
        Hash(values).each_with_object(Hashie::Mash.new) do |(key, val), obj|
          obj[key] = Value.new(key, val)
        end
    end

    def respond_to_missing?(name, *)
      @values.respond_to?(name) || super
    end

    def method_missing(name, *args)
      @values.respond_to?(name) ? @values.send(name, *args) : super
    end
  end
end
