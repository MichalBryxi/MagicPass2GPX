require 'nokogiri'
require 'open-uri'
require 'addressable/template'
require 'json'
require 'gpx'

LIST_URL = 'https://www.magicpass.ch/en/stations'
GEOCODE_TEMPLATE = 'https://geocode.maps.co/search/{?query*}'
OUTPUT_FILE = './Magic Pass.gpx'

features = []
list_page = Nokogiri::HTML.parse(URI.open(LIST_URL))
list_links = list_page.search('.rounded-aio-block.overflow-hidden.group.border.relative')
list_titles = list_links.map { |item| item['title'] }

list_titles.each do |title|
  puts "Processing %s" % [title]
  template = Addressable::Template.new(GEOCODE_TEMPLATE)
  uri = template.expand({
    'query' => {
      'q' => title,
    }
  })
  data = JSON.load(URI.open(uri))
  features.push({
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [data[0]['lon'], data[0]['lat']]
    },
    properties: {
      name: title
    }
  })

  sleep 2
end

geo_hash = {
    type: "FeatureCollection",
    features: features
}
gpx_file = GPX::GeoJSON.convert_to_gpx(geojson_data: JSON.generate(geo_hash))

File.write(OUTPUT_FILE, gpx_file)