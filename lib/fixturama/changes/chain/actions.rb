class Fixturama::Changes::Chain
  #
  # @private
  # Keep arguments of a message chain along with the corresponding actions
  #
  class Actions
    def next
      @list.count > 1 ? @list.pop : @list.first
    end

    private

    def initialize(*list)
      list = [{ return: nil }] if list.empty?

      @list = list.flatten.reverse.flat_map do |item|
        action = build(item)
        [action] * action.repeat
      end
    end

    def build(item)
      item = Hash(item).transform_keys(&:to_sym)
      case item.slice(:return, :raise).keys
      when %i[return] then ReturnAction.new(item)
      when %i[raise]  then RaiseAction.new(item)
      else raise Fixturama::FixtureError.new("an action", item)
      end
    end
  end
end
