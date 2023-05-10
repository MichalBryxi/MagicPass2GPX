# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'addressable/template'
require 'json'
require 'gpx'

LIST_URL = 'https://www.magicpass.ch/en/stations'
GEOCODE_TEMPLATE = 'https://geocode.maps.co/search/{?query*}'
OUTPUT_FILE = './Magic Pass.gpx'
LIST_CSS = '.rounded-aio-block.overflow-hidden.group.border.relative'
COUNTY_CSS = '.text-gray-500.text-xs.block.break-words'

template = Addressable::Template.new(GEOCODE_TEMPLATE)
gpx_file = GPX::GPXFile.new

list_page = Nokogiri::HTML.parse(URI.open(LIST_URL))
list_links = list_page.search(LIST_CSS)
places = list_links.map { |item| { name: item['title'], county: item.search(COUNTY_CSS).text.strip } }

places.each do |place|
  puts format('Processing %<name>s', name: place[:name])

  query_string = format('%<county>s, %<name>s, Switzerland', county: place[:county], name: place[:name])
  query = {
    query: {
      q: query_string
    }
  }
  uri = template.expand(query)
  data = JSON.load(URI.open(uri))
  if data[0]
    waypoint = {
      name: place[:name],
      lat: data[0]['lat'],
      lon: data[0]['lon'],
      desc: data[0]['display_name'],
      url: uri
    }
    gpx_file.waypoints << GPX::Waypoint.new(waypoint)
  else
    puts data
  end

  sleep 2
end

gpx_file.write(OUTPUT_FILE)
