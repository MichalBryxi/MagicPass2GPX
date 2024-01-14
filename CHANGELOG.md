# Changelog

## [0.4.2] - 2023-01-14

### Added

- Snow levels are now with cute snowflake emoji.

### Fixed

- Script is now more resilient by being able to work with dashes in place name (as well as with brackets).

## [0.4.1] - 2023-12-30

### Fixed

- Snow situation is now directly in point name.

## [0.4.0] - 2023-12-30

### Fixed

- Geolocation provider now requires API_KEY.
- Correctly implemented waiting for API throttling.

### Added

- GPX description now contains current snow conditions.

## [0.3.0] - 2023-06-23

### Added

- The logging output now shows three emojis to tell the state of given place:
   - 🚪 - closed
   - 🪂 - open
   - 🤷 - partially open

## [0.2.1] - 2023-05-25

### Fixed

- Rubygem `gpx` is now not pinned to GitHub URL, but [to v1.1.0](https://github.com/dougfales/gpx/issues/48#event-9285426721)

## [0.2.0] - 2023-05-20

### Added

- Add symbols to distinguish **currently** open vs closed places.
  - Symbols are chosen against standard [Locus](https://www.locusmap.app/) icons.
  - Closed is red cross.
  - Open is green circle.
  - Partially open is yellow triangle.
- Script now shows which places were correctly geocoded and which not.

### Fixed

- Some places with complex names were not correctly geocoded.

## [0.1.0] - 2023-05-10

### Added

- Initial implementation.