# MagicPass2GPX
Download list of current [magicpass.ch][1] places as GPX.
It uses [geocode.maps.co][2] API to guess the GPS location of individual places,
so it might not be precise or correct at all in some cases.

Latest processed file is available at [Magic Pass.gpx][3].

## Requirements
```sh
brew install rbenv
brew install openssl

# See: https://github.com/rbenv/ruby-build/discussions/2061
mkdir -p  /usr/local/etc/openssl/certs/
ln -s /usr/local/etc/openssl@3/cert.pem /usr/local/etc/openssl/certs/cert.pem 
```

## Installation
```sh
bundle install
```

## Usage

```sh
bundle exec ruby index.rb
```

## Screenshots

![Screenshot](docs/screenshot.png)

[1]: https://www.magicpass.ch/en/stations
[2]: https://geocode.maps.co
[3]: Magic%20Pass.gpx

