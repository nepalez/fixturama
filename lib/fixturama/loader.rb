#
# @private
# Load fixture with some options
#
class Fixturama::Loader
  require_relative "loader/value"
  require_relative "loader/context"

  def call
    return load_yaml if yaml?
    return load_json if json?

    content
  end

  private

  def initialize(example, path, opts = {})
    @example = example
    @path = path
    @opts = opts.to_h
  end

  def basename
    @basename ||= Pathname.new(@path).basename.to_s
  end

  def yaml?
    !basename[YAML_EXTENSION].nil?
  end

  def json?
    !basename[JSON_EXTENSION].nil?
  end

  def context
    @context ||= Context.new(@example, @opts)
  end

  def content
    bindings = context.instance_eval { binding }
    content  = File.read(@path)

    ERB.new(content).result(bindings)
  end

  def load_yaml
    finalize YAML.load(content)
  end

  def load_json
    finalize JSON.parse(content)
  end

  # Takes the nested data loaded from YAML or JSON-formatted fixture,
  # and serializes its leafs to the corresponding values from a context
  def finalize(data)
    case data
    when Array
      data.map { |val| finalize(val) }
    when Hash
      data.each_with_object({}) { |(key, val), obj| obj[key] = finalize(val) }
    when String
      finalize_string(data)
    else
      data
    end
  end

  # Converts strings of sort `#<Fixturama::Loader::Context[:key]>`
  # to the corresponding value by the key
  # @param  [String] string
  # @return [Object]
  def finalize_string(string)
    Marshal.restore(string)
  rescue StandardError
    key = string.match(Value::MATCHER)&.captures&.first&.to_s
    key ? context[key] : string
  end

  # Matchers for YAML/YML/JSON in file extension like "data.yml.erb" etc.
  YAML_EXTENSION = /.+\.ya?ml(\.|\z)/i.freeze
  JSON_EXTENSION = /.+\.json(\.|\z)/i.freeze
end
