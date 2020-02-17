class Fixturama::Changes::Request
  #
  # @private
  # Store data for a response to the corresponding request
  #
  class Response
    # @!attribute [r] repeat A number of times the response to be repeated
    # @return [Integer]
    attr_reader :repeat

    # @!attribute [r] to_h A hash for the +to_respond(...)+ part of the stub
    # @return [Hash<Symbol, Object>]
    attr_reader :to_h

    private

    def initialize(options)
      @options = options
      @options = with_error { Hash(options).transform_keys(&:to_sym) }
      @to_h    = build_hash
      @repeat  = build_repeat
    end

    def build_repeat
      with_error("number of repeats") do
        value = @options.fetch(:repeat, 1).to_i
        value.positive? ? value : raise("Wrong value")
      end
    end

    def build_hash
      { status: status, body: body, headers: headers }.select { |_, v| v }
    end

    def status
      with_error("status") { @options[:status]&.to_i } || 200
    end

    def body
      with_error("body") do
        case @options[:body]
        when NilClass then nil
        when Hash then JSON.dump(@options[:body])
        else @options[:body].to_s
        end
      end
    end

    def headers
      with_error("headers") do
        Hash(@options[:headers]).map { |k, v| [k.to_s, v.to_s] }.to_h
      end
    end

    def with_error(part = nil)
      yield
    rescue StandardError => err
      object = ["a response", part].compact.join(" ")
      raise Fixturama::FixtureError.new(object, options, err)
    end
  end
end
