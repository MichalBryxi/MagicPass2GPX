require 'nokogiri'
require 'open-uri'
require 'addressable/template'
require 'json'
require 'gpx'

LIST_URL = 'https://www.magicpass.ch/en/stations'
GEOCODE_TEMPLATE = 'https://geocode.maps.co/search/{?query*}'
OUTPUT_FILE = './Magic Pass.gpx'

list_page = Nokogiri::HTML.parse(URI.open(LIST_URL))
list_links = list_page.search('.rounded-aio-block.overflow-hidden.group.border.relative')
list_titles = list_links.map { |item| item['title'] }
gpx_file = GPX::GPXFile.new

list_titles.each do |title|
  puts "Processing %s" % [title]
  template = Addressable::Template.new(GEOCODE_TEMPLATE)
  uri = template.expand({
    'query' => {
      'q' => title,
    }
  })
  data = JSON.load(URI.open(uri))
  if data[0]
    gpx_file.waypoints << GPX::Waypoint.new({
      name: title,
      lat: data[0]['lat'],
      lon: data[0]['lon'],
      sym: 'Waypoint'
    })
  else
    puts data
  end

  sleep 2
end

gpx_file.write(OUTPUT_FILE)