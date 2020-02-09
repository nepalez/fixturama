class Fixturama::Stubs::Request
  class Responses
    def next
      list.count > @count ? list[@count].tap { @count += 1 } : list.last
    end

    private

    def initialize(list)
      @count = 0
      list ||= [{ status: 200 }]
      @list = case list
              when Array then list.map { |item| Response.new(item).to_h }
              else [Response.new(list).to_h]
              end
    end

    attr_reader :list
  end
end
