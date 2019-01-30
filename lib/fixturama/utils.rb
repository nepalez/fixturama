module Fixturama
  module Utils
    extend self

    def symbolize_hash(data)
      Hash(data).transform_keys { |key| key.to_s.to_sym }
    end

    def symbolize_array(data)
      Array(data).map { |item| item.to_s.to_sym }
    end

    def constantize(item)
      item.to_s.constantize
    end

    def clone(item)
      item.respond_to?(:dup) ? item.dup : item
    end
  end
end
