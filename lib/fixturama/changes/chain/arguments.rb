class Fixturama::Changes::Chain
  #
  # @private
  # Keep a set of arguments along with the corresponding actions to be done
  #
  class Arguments
    # @return [Array<Object>] the collection of arguments
    attr_reader :arguments

    # Order of comparing this set of arguments with the actual ones
    # @return [Integer]
    def order
      -arguments.count
    end

    # Compare definitions by sets of arguments
    # @param [Fixturama::Changes::Chain::Arguments] other
    # @return [Boolean]
    def ==(other)
      other.arguments == arguments
    end

    # If actual arguments are covered by the current ones
    def match?(*args, **opts)
      return false if arguments.count > args.count + 1

      arguments.first(args.count).zip(args).each do |(expected, actual)|
        return false unless actual == expected
      end

      if arguments.count > args.count
        Hash(arguments.last).transform_keys(&:to_sym).each do |k, v|
          return false unless opts[k] == v
        end
      end

      true
    end

    # Call the corresponding action if actual arguments are matched
    def call
      @actions.next.call
    end

    private

    def initialize(options)
      @arguments = extract(options, :arguments)
      @actions = Actions.new(*extract(options, :actions))
    end

    def extract(options, key)
      return [] unless options.key?(key)

      source = options[key]
      source.is_a?(Array) ? source : [source]
    end
  end
end
