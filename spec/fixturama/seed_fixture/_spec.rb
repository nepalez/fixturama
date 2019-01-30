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
    expect(FactoryBot).to receive(:create).and_return(bar: 99, baz: 77, qux: 42)

    subject
  end
end
