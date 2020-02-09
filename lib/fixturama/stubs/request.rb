#
# Stubbed request
#
class Fixturama::Stubs::Request
  require_relative "request/response"
  require_relative "request/responses"

  def to_s
    "#{http_method.upcase} #{uri.to_s == "" ? "*" : uri}"
  end
  alias to_str to_s

  # every stub is unique
  alias key hash
  def update!(_); end

  def apply!(example)
    stub = example.stub_request(http_method, uri)
    stub = stub.with(request) if request.any?
    stub.to_return { |_| responses.next }
  end

  private

  attr_reader :options

  def initialize(options)
    @options = options
    with_error { @options = Hash(options).symbolize_keys }
  end

  HTTP_METHODS = %i[get post put patch delete head options any].freeze

  def http_method
    value = with_error("method") { options[:method]&.to_sym&.downcase } || :any
    return value if HTTP_METHODS.include?(value)

    raise ArgumentError, "Invalid HTTP method #{value} in #{@optons}"
  end

  def uri
    with_error("uri") { maybe_regexp(options[:uri] || options[:url]) }
  end

  def headers
    with_error("headers") do
      Hash(options[:headers]).transform_keys(&:to_s) if options.key?(:headers)
    end
  end

  def query
    with_error("query") do
      Hash(options[:query]).transform_keys(&:to_s) if options.key?(:query)
    end
  end

  def body
    with_error("body") do
      case options[:body]
      when NilClass then nil
      when Hash then options[:body]
      else maybe_regexp(options[:body])
      end
    end
  end

  def basic_auth
    with_error("basic auth") do
      value = options[:auth] || options[:basic_auth]
      Hash(value).transform_keys(&:to_s).values_at("user", "pass") if value
    end
  end

  def request
    @request ||= {
      headers: headers,
      body: body,
      query: query,
      basic_auth: basic_auth
    }.select { |_, val| val }
  end

  def responses
    @responses ||= Responses.new(options[:response] || options[:responses])
  end

  def with_error(part = nil)
    yield
  rescue RuntimeError
    message = ["Cannot extract a request", part, "from #{options}"].join(" ")
    raise ArgumentError, message, __FILE__, __LINE__ - 1
  end

  def maybe_regexp(str)
    str = str.to_s
    str[%r{\A/.*/\z}] ? Regexp.new(str[1..-2]) : str
  end
end
