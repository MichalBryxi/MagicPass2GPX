# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'addressable/template'
require 'json'
require 'gpx'
require 'dotenv/load'

LIST_URL          = 'https://www.magicpass.ch/en/stations'
GEOCODE_TEMPLATE  = 'https://geocode.maps.co/search/{?query*}'
OUTPUT_GPX        = './Magic Pass.gpx'
OUTPUT_PREVIEW    = './Magic Pass.preview.geojson'

STATION_CSS       = '.rounded-aio-block.overflow-hidden.group.border.relative'
COUNTY_CSS        = '.text-gray-500.text-xs.block.break-words'
STATUS_CSS        = '.opening-state'
SNOW_CSS          = '.flex.gap-x-6.items-center .font-bold'

STATUS_ICONS = {
  Open:      { icon: 'z-ico13' },
  Closed:    { icon: 'z-ico02' },
  Partially: { icon: 'z-ico20' }
}.freeze

# Minimal color map for GitHub’s map renderer (points only)
STATUS_COLORS = {
  Open:      '#00cc66', # green
  Closed:    '#cc3333', # red
  Partially: '#ffcc00'  # yellow
}.freeze

API_KEY = ENV['API_KEY']

gpx_file = GPX::GPXFile.new
geojson_features = []

# -------- scrape --------
list_page    = Nokogiri::HTML(URI.open(LIST_URL))
station_divs = list_page.css(STATION_CSS)

places = station_divs.map do |station|
  {
    name:   station['title'].to_s.strip,
    county: station.at_css(COUNTY_CSS)&.text.to_s.strip,
    state:  station.at_css(STATUS_CSS)&.text.to_s.strip,
    snow:   station.css(SNOW_CSS)[1]&.text&.strip
  }
end

# -------- geocode helpers --------
def geocode(name, county)
  parts = ["#{county}, #{name}", name]
  if (m = name.match(/(.*)[\(-](.*)[\)-](.*)/))
    parts.concat(m.captures.map(&:strip))
  end
  parts.each do |q|
    res = geocode_string(q)
    return res if res
  end
  nil
end

def geocode_string(query_string)
  return nil if query_string.strip.empty?
  sleep 1 # be gentle
  template = Addressable::Template.new(GEOCODE_TEMPLATE)
  uri = template.expand(query: { q: query_string, api_key: API_KEY })
  response = URI.open(uri).read
  json = JSON.parse(response)
  json[0]
rescue StandardError => e
  warn "Error geocoding '#{query_string}': #{e.message}"
  nil
end

# -------- build GPX + GeoJSON --------
places.each do |place|
  data = geocode(place[:name], place[:county])
  if data
    state_key     = place[:state].to_s.strip.to_sym
    icon_info     = STATUS_ICONS[state_key] || { icon: 'unknown' }
    marker_color  = STATUS_COLORS[state_key] || '#808080'

    lat = data['lat'].to_f
    lon = data['lon'].to_f

    # GPX waypoint
    gpx_file.waypoints << GPX::Waypoint.new(
      name: "#{place[:name]}, ❄️ #{place[:snow]}",
      sym:  icon_info[:icon],
      lat:  lat,
      lon:  lon,
      desc: data['display_name']
    )

    # GeoJSON point (only marker-color; no emojis, no polygons)
    geojson_features << {
      type: 'Feature',
      geometry: { type: 'Point', coordinates: [lon, lat] },
      properties: {
        name: place[:name],
        county: place[:county],
        status: place[:state],
        snow: place[:snow],
        'marker-color' => marker_color
      }
    }

    puts "✓ #{place[:name]} (#{place[:state]})"
  else
    puts "✗ #{place[:name]} (geocode failed)"
  end
end

# -------- write outputs --------
gpx_file.write(OUTPUT_GPX)
File.write(
  OUTPUT_PREVIEW,
  JSON.dump({ type: 'FeatureCollection', features: geojson_features })
)

puts "Wrote GPX:     #{OUTPUT_GPX}"
puts "Wrote preview: #{OUTPUT_PREVIEW}"