# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Not released

### Added

- Support for stubbing ENV variables (nepalez)

```yaml
---
- env: GOOGLE_CLOUD_KEY
  value: foo

- env: GOOGLE_CLOUD_PASSWORD
  value: bar
```

This would stub selected variables only, not touching the others

## [0.3.0] - [2020-03-08]

### Added

- Support for exception arguments (nepalez)

```yaml
---
- class: API
  chain: get_product
  arguments:
    - 1
  actions:
    - raise: API::NotFoundError
      arguments: # <--- that's that
        - "Cannot find a product by id: 1"
```

which would raise `API::NotFoundError.new("Cannot find a product by id: 1")`

## [0.2.0] - [2020-02-17]

### Added

- Stubbing and seeding from the same source file via the `call_fixture` method (nepalez)

```yaml
# ./changes.yml
---
- type: user
  params:
    id: 1

- const: DEFAULT_USER_ID
  value: 1

- url: https://example.com/users/default
  method: get
  responses:
    - body:
        id: 1
        name: Andrew
```

```ruby
before { call_fixture "#{__dir__}/changes.yml" }
```

## [0.1.0] - [2020-02-09]

### Added

- Stubbing of the HTTP requests using webmock (nepalez)

  ```yaml
  ---
  - url: example.com/foo
    method: get
    body: foobar
    query:
      foo: bar
    basic_auth:
      user: foo
      password: bar
    headers:
      Accept: utf-8
    responses:
      - status: 200
        body: foobar
      - status: 404
  ```

## [0.0.7] - [2019-07-01]

### Added

- Stubbing of an arbitrary option (nepalez)

  ```yaml
  ---
  - object: Rails.application
    chain:
      - env
    actions:
      - return: production
  ```

### Changed

- Partially defined options will satisfy an expectation (nepalez)

  ```yaml
  ---
  - class: Payment
    chain:
      - call
    arguments:
      - 1
      - :overdraft: true
    actions:
      - return: 3
  ```
  
  This works even though the key `:notify` was not defined by the stub:

  ```ruby
  Payment.call 1, overdraft: true, notify: true
  ```
  
  Notice, that these method works for key arguments only
  (symbolized hash as the last argument).


## [0.0.6] - [2019-06-09]

### Added

- Better matching of YAML/JSON files (nepalez)

  The loader recognizes complex extensions like `data.yml.erb`
  or `data.json.erb`, as well as `data.YAML` in upper register.

- Support for Ruby objects (including Activerecord models) serialization
  in the parameters of fixtures (nepalez)
  
  You can send objects, that are stringified in a default Ruby way,
  into fixture loaders (seeds, stubs etc.) via ERB bindings.
  Those objects will be gracefully inserted into the resulting structure:
  
  ```yaml
  ---
  :account: <%= user %>
  ```
  
  ```ruby
  let(:user) { FactoryBot.create :user }
  subject    { load_fixture "#{__dir__}/output.yml", user: user }

  # The `user` object has been bound via ERB
  it { is_expected.to eq account: user }
  ```
  
  This feature can be used for adding RSpec [matching arguments](https://relishapp.com/rspec/rspec-mocks/v/3-8/docs/setting-constraints/matching-arguments):

  ```yaml
  ---
  :foo: <%= foo %>
  :bar: 3
  ```
  
  ```ruby
  # Use the RSpec `anyting` matcher
  subject { { foo: 4, bar: 3 } }
  
  let(:template) { load_fixture "#{__dir__}/template.yml", foo: anyting }
  
  # The `anyting` has been bound via ERB to the template
  # Compare `{ foo: 4, bar: 3 }` to the template `{ foo: anything, bar: 3 }`
  it { is_expected.to include(template) }
  ```
  
  **Be careful though**: the trick won't work with objects whose default method `Object#to_s` has been overloaded.
  
## [0.0.5] - [2018-06-04]

### Added

- Support for stubbing constants (nepalez)

  ```yaml
  # Stub constant TIMEOUT_SEC to 10
  ---
  - const: TIMEOUT_SEC
    value: 10
  ```

## [0.0.4] - [2018-05-22]

### Added

- The `:count` option for a number of objects to seed at once (nepalez)

  ```yaml
  # Seed 3 customers
  ---
  - type: user
    count: 3
    traits:
      - customer
  ```

## [0.0.3] - [2018-05-04]

### Added

- Helper method to configuge start ids (sclinede, nepalez)

  ```ruby
  RSpec.configure do |c|
    c.before(:suite) { Fixturama.start_ids_from(1_000_000_000) }
  end
  ```

## [0.0.2] - [2018-04-27]

### Added

- Restriction of stub by arguments (nepalez)

  ```yaml
  ---
  - class: Balance
    chain: debet
    arguments: 0
    actions:
      - return: 1

  - class: Balance
    chain: debet
    arguments: 1
    actions:
      - return: 0
      - raise: UnsifficientFunds

  - class: Balance
    chain: debet
    arguments: 2
    actions:
      - raise: UnsifficientFunds
  ```

## [0.0.1] - [2018-03-01]

This is a first public release with features extracted from production app.

[0.0.1]: https://github.com/nepalez/fixturama/releases/tag/v0.0.1
[0.0.2]: https://github.com/nepalez/fixturama/compare/v0.0.1...v0.0.2
[0.0.3]: https://github.com/nepalez/fixturama/compare/v0.0.2...v0.0.3
[0.0.4]: https://github.com/nepalez/fixturama/compare/v0.0.3...v0.0.4
[0.0.5]: https://github.com/nepalez/fixturama/compare/v0.0.4...v0.0.5
[0.0.6]: https://github.com/nepalez/fixturama/compare/v0.0.5...v0.0.6
[0.0.7]: https://github.com/nepalez/fixturama/compare/v0.0.6...v0.0.7
[0.1.0]: https://github.com/nepalez/fixturama/compare/v0.0.7...v0.1.0
[0.2.0]: https://github.com/nepalez/fixturama/compare/v0.1.0...v0.2.0
[0.3.0]: https://github.com/nepalez/fixturama/compare/v0.2.0...v0.3.0
