# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
