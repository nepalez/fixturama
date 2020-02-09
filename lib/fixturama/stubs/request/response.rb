class Fixturama::Stubs::Request
  class Response
    def to_h
      { status:  status, body: body, headers: headers }.select { |_, val| val }
    end

    private

    def initialize(options)
      @options = options
      @options = with_error { Hash(options).transform_keys(&:to_sym) }
    end

    attr_reader :options

    def status
      with_error("status") { options[:status]&.to_i } || 200
    end

    def body
      with_error("body") do
        case options[:body]
        when NilClass then nil
        when Hash then JSON.dump(options[:body])
        else options[:body].to_s
        end
      end
    end

    def headers
      with_error("headers") do
        Hash(options[:headers]).map { |k, v| [k.to_s, v.to_s] }.to_h
      end
    end

    def with_error(part = nil)
      yield
    rescue RuntimeError
      text = ["Cannot extract a response", part, "from #{options}"].join(" ")
      raise ArgumentError, text, __FILE__, __LINE__ - 1
    end
  end
end
