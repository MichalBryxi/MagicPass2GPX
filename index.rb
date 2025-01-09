# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'addressable/template'
require 'json'
require 'gpx'
require 'dotenv/load'

LIST_URL          = 'https://www.magicpass.ch/en/stations'
GEOCODE_TEMPLATE  = 'https://geocode.maps.co/search/{?query*}'
OUTPUT_FILE       = './Magic Pass.gpx'
STATION_CSS       = '.rounded-aio-block.overflow-hidden.group.border.relative'
COUNTY_CSS        = '.text-gray-500.text-xs.block.break-words'
STATUS_CSS        = '.opening-state'
SNOW_CSS          = '.flex.gap-x-6.items-center .font-bold'
STATUS_ICONS = {
  Open:       { icon: 'z-ico13', emoji: '🪂' },
  Closed:     { icon: 'z-ico02', emoji: '🚪' },
  Partially:  { icon: 'z-ico20', emoji: '🤷' }
}.freeze
API_KEY = ENV['API_KEY']

gpx_file = GPX::GPXFile.new

##
# Fetch station data from the main listing page and parse into a list of places.
#
list_page   = Nokogiri::HTML(URI.open(LIST_URL))
station_divs = list_page.css(STATION_CSS)

places = station_divs.map do |station|
  {
    name:   station['title'].to_s.strip,
    county: station.at_css(COUNTY_CSS)&.text.to_s.strip,
    state:  station.at_css(STATUS_CSS)&.text.to_s.strip,
    snow:   station.css(SNOW_CSS)[1]&.text&.strip
  }
end

##
# Attempt to geocode a place by name and county, falling back to
# variations of the name (extracted via a regex) if the first attempts fail.
#
def geocode(name, county)
  # Define a search priority list:
  # 1) "<county>, <name>"
  # 2) "<name>"
  # 3+) Regex-captured parts of <name> (useful if the name has parentheses, dashes, etc.)
  parts = [
    "#{county}, #{name}",
    name
  ]

  # If name has a pattern like "Something (Extra) - Another"
  # match_data.captures => ["Something ", "Extra", " - Another"]
  # Adjust or refine the regex to suit your actual naming patterns.
  if (match_data = name.match(/(.*)[\(-](.*)[\)-](.*)/))
    parts.concat(match_data.captures.map(&:strip))
  end

  data = nil
  parts.each do |p|
    data = geocode_string(p)
    break if data
  end
  data
end

##
# Make a single geocoding request using a query string.
# Returns the first matching location hash or nil if none is found.
#
def geocode_string(query_string)
  return nil if query_string.strip.empty?

  # Rate-limiting: avoid hammering the API
  sleep 1

  template = Addressable::Template.new(GEOCODE_TEMPLATE)
  uri = template.expand(query: {
    q:       query_string,
    api_key: API_KEY # If the API allows or requires it
  })

  response = URI.open(uri).read
  json_data = JSON.parse(response)
  json_data[0]
rescue StandardError => e
  warn "Error geocoding '#{query_string}': #{e.message}"
  nil
end

##
# For each place, geocode it, add a waypoint to the GPX file, and print status.
#
places.each do |place|
  data = geocode(place[:name], place[:county])
  if data
    state_key = place[:state].to_sym
    icon_info = STATUS_ICONS[state_key] || { icon: 'unknown', emoji: '❓' }

    waypoint = {
      name: "#{place[:name]}, ❄️ #{place[:snow]}",
      sym: icon_info[:icon],
      lat: data['lat'],
      lon: data['lon'],
      desc: data['display_name']
    }
    gpx_file.waypoints << GPX::Waypoint.new(waypoint)

    puts format('%<emoji>s %<name>s, ❄️ %<snow>s',
                name: place[:name],
                emoji: icon_info[:emoji],
                snow: place[:snow])
  else
    puts format('❌ %<name>s', name: place[:name])
  end
end

##
# Finally, write the GPX file.
#
gpx_file.write(OUTPUT_FILE)
puts "GPX file successfully written to: #{OUTPUT_FILE}"