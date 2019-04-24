RSpec.describe "stub_fixture" do
  subject { arguments.map { |argument| Payment.new.pay(argument) } }

  before do
    class Payment
      def pay(_)
        5
      end
    end
  end

  context "without stubbing" do
    let(:arguments) { [0] }

    it { is_expected.to eq [5] }
  end

  context "with stubbing" do
    before { stub_fixture "#{__dir__}/stub.yml" }

    context "with a :raise option" do
      let(:arguments) { [0] }

      it "raises an exception" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "with a :return option" do
      let(:arguments) { [1] }

      it "returns stubbed value" do
        expect(subject).to eq [8]
      end
    end

    context "with several actions" do
      let(:arguments) { [2] * 4 }

      it "calls the consecutive actions and then repeates the last one" do
        expect(subject).to eq [4, 2, 0, 0]
      end
    end

    context "with multi-count actions" do
      let(:arguments) { [3] * 4 }

      it "repeats the action a specified number of times" do
        expect(subject).to eq [6, 6, 0, 0]
      end
    end

    context "with several arguments" do
      let(:arguments) { [2, 3, 2, 3, 2, 3] }

      it "counts actions for every stub in isolation from the others" do
        expect(subject).to eq [4, 6, 2, 6, 0, 0]
      end
    end

    context "with unspecified argument" do
      let(:arguments) { [4] }

      it "uses universal stub" do
        expect(subject).to eq [-1]
      end
    end
  end
end
