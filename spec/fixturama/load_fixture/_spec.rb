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

  context "JSON" do
    subject { load_fixture("#{__dir__}/data.json", id: 42) }

    it { is_expected.to eq expected }
  end
end
