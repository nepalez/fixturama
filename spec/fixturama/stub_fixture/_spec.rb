RSpec.describe "stub_fixture" do
  subject { Foo.new.bar }

  before do
    class Foo
      def bar
        "bar"
      end
    end
  end

  context "without stubbing" do
    it { is_expected.to eq "bar" }
  end

  context "with first invocation" do
    before { stub_fixture "#{__dir__}/stub.yml" }

    it { is_expected.to eq "baz" }
  end

  context "with next_day invocation" do
    before do
      stub_fixture "#{__dir__}/stub.yml"
      Foo.new.bar
    end

    it "raises an exception" do
      expect { subject }.to raise_error StandardError
    end
  end

  context "with later invocations" do
    before do
      stub_fixture "#{__dir__}/stub.yml"
      3.times do begin
                  Foo.new.bar
                rescue
                  nil
                end end
    end

    it "raises an exception" do
      expect { subject }.to raise_error StandardError
    end
  end
end
