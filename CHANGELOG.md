# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-07-13

No API changes — `ReqMulti.attach/1` and the `:multi` option are unchanged.

### Changed

- Widen dependency constraints to `req ~> 0.5` and `multipart ~> 0.4`, after
  verifying the plugin works across `req` 0.5.0–0.6.2 and `multipart`
  0.4.0–0.6.1.
- Refresh `mix.lock` to the latest in-range dependencies and bump the
  development toolchain to Elixir 1.20 / OTP 29.

### Added

- Tests covering the multipart round-trip (server-side parsing of the encoded
  body), the `Content-Length` header, replacement of a pre-existing `:body`,
  `multi: nil` handling, and `attach/1` idempotency.
- Expanded module documentation and README with the `:multi` option and a
  runnable example.

## [0.1.0] - 2024-08-29

### Added

- Initial release: a [Req](https://github.com/wojtekmach/req) plugin for
  sending `multipart/form-data` request bodies via the `:multi` option.

[0.1.1]: https://github.com/tubedude/req_multipart/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/tubedude/req_multipart/releases/tag/v0.1.0
