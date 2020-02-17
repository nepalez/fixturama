class Fixturama::Changes
  #
  # @private
  # @abstract
  # Base class for changes downloaded from a fixture
  #
  class Base
    # @!attribute [r] key The key identifier of the change
    # @return [String]
    alias key hash

    # Merge the other change into the current one
    # @param [Fixturama::Changes::Base] other
    # @return [Fixturama::Changes::Base]
    def merge(other)
      # By default just take the other change if applicable
      other.class == self.class && other.key == key ? other : self
    end

    # @abstract
    # Call the corresponding change (either a stub or a seed)
    # @param [RSpec::Core::Example] _example The RSpec example
    # @return [self]
    def call(_example)
      self
    end
  end
end
