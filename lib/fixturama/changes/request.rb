class Fixturama::Changes
  #
  # @private
  # Stub an HTTP(S) request using +Webmock+
  #
  class Request < Base
    require_relative "request/response"
    require_relative "request/responses"

    def call(example)
      stub = example.stub_request(http_method, uri)
      stub = stub.with(request) if request.any?
      stub.to_return { |_| responses.next }
      self
    end

    private

    attr_reader :options

    def initialize(options)
      @options = options
      with_error { @options = Hash(@options).transform_keys(&:to_sym) }
    end

    HTTP_METHODS = %i[get post put patch delete head options any].freeze

    def http_method
      with_error("http method") do
        value = with_error("method") { options[:method]&.to_sym&.downcase }
        value ||= :any
        raise("Invalid HTTP method") unless HTTP_METHODS.include?(value)
        value
      end
    end

    def uri
      with_error("uri") { maybe_regexp(options[:uri] || options[:url]) }
    end

    def headers
      with_error("headers") do
        Hash(options[:headers]).transform_keys(&:to_s) if options.key? :headers
      end
    end

    def query
      with_error("query") do
        Hash(options[:query]).transform_keys(&:to_s) if options.key?(:query)
      end
    end

    def body
      with_error("body") { maybe_regexp options[:body] }
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
    rescue StandardError => err
      part = ["a valid request", part].compact.join(" ")
      raise Fixturama::FixtureError.new(part, options, err)
    end

    def maybe_regexp(str)
      return unless str

      str = str.to_s
      str[%r{\A/.*/\z}] ? Regexp.new(str[1..-2]) : str
    end
  end
end
