# Fixturama

Collection of helpers for dealing with fixtures in [RSpec][rspec]

Read the [post about the library on dev.to][dev_to].

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

[![Gem Version](https://badge.fury.io/rb/fixturama.svg)][gem]
[![Build Status](https://travis-ci.org/nepalez/fixturama.svg?branch=master)][travis]

## Installation

```ruby
gem "fixturama"
```

## Configuration

On Rails add offsets to id sequences of database tables.

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.before(:suite) { Fixturama.start_ids_from 1_000_000 }
end
```

Now when you hardcode ids in fixtures (under 1_000_000), they won't conflict with authomatically created ones.

## Usage

```ruby
# spec/spec_helper.rb
require "fixturama/rspec"
```

The gem defines 3 helpers (support ERB bindings):

- `load_fixture(path, **opts)` to load data from a fixture, and deserialize YAML and JSON
- `seed_fixture(path_to_yaml, **opts)` to prepare database using the [FactoryBot][factory-bot]
- `stub_fixture(path_to_yaml, **opts)` to stub some classes

### Loading

```ruby
# spec/models/user/_spec.rb
RSpec.describe "GraphQL mutation 'deleteProfile'" do
  subject { Schema.execute(mutation).to_h }

  before do
    seed_fixture("#{__dir__}/database.yml", profile_id: 42)
    stub_fixture("#{__dir__}/stubs.yml",    profile_id: 42)
  end

  let(:mutation) { load_fixture "#{__dir__}/mutation.graphql", profile_id: 42 }
  let(:result)   { load_fixture "#{__dir__}/result.yaml" }

  it { is_expected.to eq result }

  it "deletes the profile" do
    expect { subject }.to change { Profile.find_by(id: 42) }.to nil
  end

  it "sends a notification" do
    expect(Notifier)
      .to receive_message_chain(:create)
      .with("profileDeleted", 42)

    subject
  end
end
```

Notice, that since the `v0.0.6` the gem also supports binding any ruby object, not only strings, booleans and numbers:

```yaml
# ./data.yml
---
account: <%= user %>
```

```ruby
# Bind activerecord model
subject { load_fixture "#{__dir__}/data.yml", user: user }

let(:user) { FactoryBot.create :user }

# The same object will be returned
it { is_expected.to eq account: user }
```

The object must be named in the options you send to the `load_fixture`, `stub_fixture`, or `seed_fixture` helpers.

This feature can also be useful to produce a "partially defined" fixtures with [RSpec argument matchers][rspec-argument-matchers]:

```ruby
subject { load_fixture "#{__dir__}/data.yml", user: kind_of(ActiveRecord::Base) }
```

Since the v0.5.0 we support another way to serialize PORO objects in fixtures. Just wrap them to the `object()` method:

```yaml
---
:account: <%= object(user) %>
```

This time you don't need sending objects explicitly.

```ruby
RSpec.describe "example" do
    subject { load_fixture "#{__dir__}/data.yml" }
    
    let(:user) { FactoryBot.create(:user) }
    
    # The same object will be returned
    it { is_expected.to eq(account: user) }
end
```

Under the hood we use `Marshal.dump` and `Marshal.restore` to serialize and deserialize the object back.

**Notice**, that deserialization creates a new instance of the object which is not equivalent to the source (`user` in the example above)!
In most cases this is enough. For example, you can provide matchers like:

```yaml
---
number: <%= object(be_positive) %>
```

The loaded object would contain `{ "number" => be_positive }`.

### Seeding

The seed (`seed_fixture`) file should be a YAML/JSON with opinionated parameters, namely:

- `type` for the name of the [FactoryBot][factory-bot] factory
- `traits` for the factory traits
- `params` for parameters of the factory

```yaml
# ./database.yml
#
# This is the same as
# `create_list :profile, 1, :active, id: profile_id`
---
- type: profile
  traits:
    - active
  params:
    id: <%= profile_id %>
```

Use the `count: 2` key to create more objects at once.

### Stubbing

The gem supports stubbing message chains, constants and http requests with the following keys.

For message chains:

- `class` for stubbed class
- `chain` for messages chain
- `arguments` (optional) for specific arguments
- `actions` for an array of actions for consecutive invocations of the chain with keys
    - `return` for a value to be returned
    - `raise` for an exception to be risen
    - `repeate` for a number of invocations with this action

For constants:

- `const` for stubbed constant
- `value` for a value of the constant

For environment variables:

- `env` for the name of a variable
  `value` for a value of the variable

For http requests:

- `url` or `uri` for the URI of the request (treats values like `/.../` as regular expressions)
- `method` for the specific http-method (like `get` or `post`)
- `body` for the request body (treats values like `/.../` as regular expressions)
- `headers` for the request headers
- `query` for the request query
- `basic_auth` for the `user` and `password` of basic authentication
- `response` or `responses` for consecutively envoked responses with keys:
    - `status`
    - `body`
    - `headers`
    - `repeate` for the number of times this response should be returned before switching to the next one

```yaml
# ./stubs.yml
#
# The first invocation acts like
#
# allow(Notifier)
#   .to receive_message_chain(:create)
#   .with(:profileDeleted, 42)
#   .and_return true
#
# then it will act like
#
# allow(Notifier)
#   .to receive_message_chain(:create)
#   .with(:profileDeleted, 42)
#   .and_raise ActiveRecord::RecordNotFound
#
---
- class: Notifier
  chain:
    - create
  arguments:
    - :profileDeleted
    - <%= profile_id %>
  actions:
    - return: true
      repeate: 1 # this is the default value
    - raise: ActiveRecord::RecordNotFound
      arguments:
        - "Profile with id: 1 not found" # for error message

# Here we stubbing a constant
- const: NOTIFIER_TIMEOUT_SEC
  value: 10

# This is a stub for ENV['DEFAULT_EMAIL']
- env: DEFAULT_EMAIL
  value: foo@example.com

# Examples for stubbing HTTP
- uri: /example.com/foo/ # regexp!
  method: delete
  basic_auth:
    user: foo
    password: bar
  responses:
    - status: 200 # for the first call
      repeate: 1   # this is the default value, but you can set another one
    - status: 404 # for any other call

- uri: htpps://example.com/foo # exact string!
  method: delete
  responses:
    - status: 401
```

```graphql
mutation {
  deleteProfile(
    input: {
      id: "<%= profile_id %>"
    }
  ) {
    success
    errors {
      message
      fields
    }
  }
}
```

```yaml
# ./result.yaml
---
data:
  deleteProfile:
    success: true
    errors: []
```

With these helpers all the concrete settings can be extracted to fixtures.

I find it especially helpful when I need to check different edge cases. Instead of polluting a specification with various parameters, I create the sub-folder with "input" and "output" fixtures for every case.

Looking at the spec I can easily figure out the "structure" of expectation, while looking at fixtures I can check the concrete corner cases.

## Single Source of Changes

If you will, you can list all stubs and seeds at the one single file like

```yaml
# ./changes.yml
---
- type: user
  params:
    id: 1
    name: Andrew

- const: DEFAULT_USER_ID
  value: 1
```

This fixture can be applied via `call_fixture` method just like we did above with `seed_fixture` and `stub_fixture`:

```ruby
before { call_fixture "#{__dir__}/changes.yml" }
```

In fact, since the `v0.2.0` all those methods are just the aliases of the `call_fixture`.

## License

The gem is available as open source under the terms of the [MIT License][license].

[gem]: https://rubygems.org/gems/fixturama
[travis]: https://travis-ci.org/nepalez/fixturama
[license]: http://opensource.org/licenses/MIT
[factory-bot]: https://github.com/thoughtbot/factory_bot
[rspec]: https://rspec.info/
[dev_to]: https://dev.to/evilmartians/a-fixture-based-approach-to-interface-testing-in-rails-2cd4
[rspec-argument-matchers]: https://relishapp.com/rspec/rspec-mocks/v/3-8/docs/setting-constraints/matching-arguments
