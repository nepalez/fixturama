RSpec.describe "load_fixture" do
  let(:expected) { { "foo" => { "bar" => 42 } } }

  context "YAML" do
    subject { load_fixture("#{__dir__}/data.yaml", id: 42) }

    it { is_expected.to eq expected }
  end

  context "YML" do
    subject { load_fixture("#{__dir__}/data.yml", id: 42) }

    it { is_expected.to eq expected }
  end

  context "YAML with ruby object" do
    subject { load_fixture("#{__dir__}/data.yaml", id: foobar) }

    before { class Test::Foobar; end }

    let(:foobar)   { Test::Foobar.new }
    let(:expected) { { "foo" => { "bar" => foobar } } }

    it { is_expected.to eq expected }
  end

  context "object in YAML" do
    subject { load_fixture("#{__dir__}/object.yaml") }

    before { Test::Foobar = Struct.new(:foo, :bar) }

    # accessible from object.yaml as object(foobar)
    let!(:foobar) { Test::Foobar.new(foo: 1, bar: 2) }
    let(:expected) { { "foo" => { "bar" => foobar } } }

    it { is_expected.to eq expected }
  end

  context "JSON" do
    subject { load_fixture("#{__dir__}/data.json", id: 42) }

    it { is_expected.to eq expected }
  end

  context "JSON with ruby object" do
    subject { load_fixture("#{__dir__}/data.json", id: foobar) }

    before { class Test::Foobar; end }

    let(:foobar)   { Test::Foobar.new }
    let(:expected) { { "foo" => { "bar" => foobar } } }

    it { is_expected.to eq expected }
  end

  context "with RSpec argument matchers" do
    subject { load_fixture("#{__dir__}/data.yaml", id: kind_of(Numeric)) }

    it "loads the matcher", aggregate_failures: true do
      expect("foo" => { "bar" => 42 }).to include subject
      expect("foo" => { "bar" => 99 }).to include subject
      expect("foo" => { "bar" => :a }).not_to include subject
    end
  end
end
