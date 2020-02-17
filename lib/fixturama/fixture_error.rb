#
# The exception complaining about invalid definition in some fixture
#
class Fixturama::FixtureError < ArgumentError
  # The error message
  # @return [String]
  def message
    <<~MESSAGE
      Cannot infer #{@object} from the following part of the fixture #{@file}:
      #{@data}
    MESSAGE
  end

  # @private
  # Add reference to the path of the fixture file
  # @param [String] file
  # @return [self]
  def with_file(file)
    @file = file
    self
  end

  private

  def initialize(object, data, _cause = nil)
    @object = object
    @data = YAML.dump(data)

    super message
  end
end
