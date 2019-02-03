module Fixturama
  module Seed
    module_function

    def call(opts)
      opts   = Utils.symbolize_hash(opts)
      type   = opts[:type].to_sym
      traits = Utils.symbolize_array opts[:traits]
      params = Utils.symbolize_hash  opts[:params]

      FactoryBot.create(type, *traits, **params)
    end
  end
end
