RSpec.describe "seed_fixture" do
  subject { seed_fixture "#{__dir__}/seed.yml" }

  before do
    FactoryBot.define do
      factory :foo, class: Hash do
        transient do
          bar { 0 }
          baz { 0 }
          qux { 0 }
        end

        trait :bar do
          bar { 99 }
        end

        trait :baz do
          baz { 77 }
        end

        skip_create
        initialize_with { { bar: bar, baz: baz, qux: qux } }
      end
    end
  end

  it "runs the factory", aggregate_failures: true do
    expect(FactoryBot).to receive(:create_list).with(:foo, 1, :baz, qux: 42)

    expect(FactoryBot).to receive(:create_list) do |*args, **opts|
      expect(args).to eq [:foo, 3, :bar]
      expect(opts).to be_empty
    end

    subject
  end
end
