# Matter Hooks Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][kac], and this project adheres to
[Semantic Versioning][semver].

[kac]: https://keepachangelog.com/en/1.1.0/
[semver]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

## [0.1.0] - 2023-03-18

### Added

- Several hooks:
  - `useAsync` - Calls and memoizes an asynchronous function when the provided
    dependencies change.
  - `useChange` - Determines when the provided dependencies change.
  - `useContextAction` - Registers asynchronous context actions within systems.
  - `useMap` - Retrieves a value from a map using a key.
  - `useMemo` - Returns a memoized value. Only recalculates when the provided
    dependencies change.
  - `useReducer` - Returns a state updated by a reducer as well as a dispatcher
    for that reducer.
  - `useStream` - Returns a loop iterator to process instance streaming events
    for a provided streaming ID attribute, and optionally, its descendants as
    they stream.

[unreleased]: https://github.com/LastTalon/matter-hooks/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/LastTalon/matter-hooks/releases/tag/v0.1.0
