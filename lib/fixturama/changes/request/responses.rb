class Fixturama::Changes::Request
  #
  # @private
  # Iterate by a consecutive responses to the request
  #
  class Responses
    # @return [Fixturama::Changes::Request::Response]
    def next
      @list.count > 1 ? @list.pop : @list.first
    end

    private

    def initialize(*list)
      list = [{ status: 200 }] if list.empty?
      @list = list.flatten.reverse.flat_map do |item|
        response = Response.new(item)
        [response.to_h] * response.repeat
      end
    end
  end
end
