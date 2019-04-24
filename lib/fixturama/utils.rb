module Fixturama
  module Utils
    module_function

    def symbolize(item)
      item.to_s.to_sym
    end

    def symbolize_hash(data)
      Hash(data).transform_keys { |key| symbolize(key)}
    end

    def symbolize_array(data)
      Array(data).map { |item| symbolize(item) }
    end

    def constantize(item)
      Kernel.const_get(item.to_s)
    end

    def clone(item)
      item.respond_to?(:dup) ? item.dup : item
    end

    def array(list)
      case list
      when NilClass then []
      when Array    then list
      else [list]
      end
    end
  end
end
