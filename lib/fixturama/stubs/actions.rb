module Fixturama
  #
  # Factory to provide a specific action from options
  #
  module Stubs::Actions
    extend self

    require_relative "actions/raise"
    require_relative "actions/return"

    #
    # Builds an action
    # @option [#to_s]  :raise
    # @option [Object] :return
    # @option [true]   :call_original
    # @return [#call] a callable action
    #
    def build(stub, **options)
      check!(stub, options)
      key, value = options.to_a.first
      TYPES[key].new(stub, value)
    end

    private

    def check!(stub, options)
      keys = options.keys & TYPES.keys
      return if keys.count == 1

      raise SyntaxError, <<~MESSAGE.squish
        Invalid settings for stubbing message chain #{stub}: #{options}.
        The action MUST have one and only one of the keys:
        `#{TYPES.keys.join('`, `')}`.
      MESSAGE
    end

    TYPES = { raise: Raise, return: Return }.freeze
  end
end
