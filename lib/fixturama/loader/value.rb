class Fixturama::Loader
  #
  # Wraps a value with a reference to its key
  # in the [Fixturama::Loader::Context]
  #
  class Value
    # Regex mather to extract value key from the stringified wrapper
    MATCHER = /\A\#\<Fixturama::Loader::Context\[([^\]]+)\]\>\z/.freeze

    def self.new(key, value)
      case value
      when String, Symbol, Numeric, TrueClass, FalseClass, NilClass then value
      else super
      end
    end

    # The sting representing the value with a reference to it in bindings
    def to_s
      "\"#<Fixturama::Loader::Context[#{@key}]>\""
    end
    alias to_str to_s

    private

    def initialize(key, value)
      @key   = key
      @value = value
    end

    def method_missing(name, *args, &block)
      @value.respond_to?(name) ? @value.send(name, *args, &block) : super
    end

    def respond_to_missing?(name, *)
      @value.respond_to?(name) || super
    end
  end
end
