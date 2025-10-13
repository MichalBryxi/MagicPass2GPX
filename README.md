# MagicPass2GPX

Download list of current [magicpass.ch][1] places as GPX.
It uses [geocode.maps.co][2] API to guess the GPS location of individual places,
so it might not be precise or correct at all in some cases.

Latest processed file is available at [Magic Pass.gpx][3].

## Requirements

```sh
brew install rbenv
brew install openssl
```

## Installation

```sh
bundle install
cp .env.example .env
vim .env # Edit API_KEY
```

## Usage

```sh
bundle exec ruby index.rb
```

## Screenshots

![Screenshot](docs/screenshot.png)

## Rendered

<!-- BEGIN: AUTO-GEOJSON -->
<!-- END: AUTO-GEOJSON -->

[1]: https://www.magicpass.ch/en/stations
[2]: https://geocode.maps.co
[3]: Magic%20Pass.gpx
