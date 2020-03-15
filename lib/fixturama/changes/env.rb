class Fixturama::Changes
  #
  # @private
  # Stub an environment variable
  #
  class Env < Base
    # All changes has the same +key+
    # They will be merged before stubbing (see +call+)
    def key
      "ENV"
    end

    # When we merge 2 env-s, we just merge their options
    def merge(other)
      return self unless other.is_a?(self.class)
      dup.tap { |env| env.options.update(other.options) }
    end

    def call(example)
      original = Hash ENV
      example.send(:stub_const, "ENV", original.merge(options))
      self
    end

    protected

    attr_reader :options

    private

    def initialize(**options)
      @options = { options[:env].to_s => options[:value].to_s }
    end
  end
end
