module Fixturama
  module Seed
    module_function

    def call(opts)
      opts   = Utils.symbolize_hash(opts)
      type   = opts[:type].to_sym
      traits = Utils.symbolize_array opts[:traits]
      params = Utils.symbolize_hash  opts[:params]
      count  = opts.fetch(:count, 1).to_i

      FactoryBot.create_list(type, count, *traits, **params) if count.positive?
    end
  end
end
