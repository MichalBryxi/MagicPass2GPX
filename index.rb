require 'nokogiri'
require 'open-uri'
require 'addressable/template'
require 'json'
require 'gpx'

LIST_URL = 'https://www.magicpass.ch/en/stations'.freeze
GEOCODE_TEMPLATE = 'https://geocode.maps.co/search/{?query*}'.freeze
OUTPUT_FILE = './Magic Pass.gpx'.freeze

template = Addressable::Template.new(GEOCODE_TEMPLATE)
list_page = Nokogiri::HTML.parse(URI.open(LIST_URL))
list_links = list_page.search('.rounded-aio-block.overflow-hidden.group.border.relative')
places = list_links.map { |item| { name: item['title'], county: item.search('.text-gray-500.text-xs.block.break-words').text.strip } }
gpx_file = GPX::GPXFile.new

places.each do |place|
  puts format('Processing %<name>s', name: place[:name])

  query_string = format('%<county>s, %<name>s, Switzerland', county: place[:county], name: place[:name])
  uri = template.expand({
    query: {
      q: query_string,
    }
  })
  data = JSON.load(URI.open(uri))
  if data[0]
    gpx_file.waypoints << GPX::Waypoint.new({
      name: place[:name],
      lat: data[0]['lat'],
      lon: data[0]['lon'],
      desc: data[0]['display_name'],
      url: uri
    })
  else
    puts data
  end

  sleep 2
end

gpx_file.write(OUTPUT_FILE)