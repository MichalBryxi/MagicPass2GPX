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
STATUS_CSS = '.opening-state'
STATUS_ICONS = {
  Open: 'z-ico13',
  Closed: 'z-ico02',
  Partially: 'z-ico20'
}

gpx_file = GPX::GPXFile.new

list_page = Nokogiri::HTML.parse(URI.open(LIST_URL))
list_links = list_page.search(LIST_CSS)
places = list_links.map do |item|
  {
    name: item['title'],
    county: item.search(COUNTY_CSS).text.strip,
    state: item.search(STATUS_CSS).text.strip
  }
end

def geocode(name, county)
  county_and_name = format('%<county>s, %<name>s', county: county, name: name)
  parts_of_name = name.match(/(.*)\((.*)\)(.*)/)
  data = geocode_string(county_and_name)
  data ||= geocode_string(name)
  data ||= geocode_string(parts_of_name[0])
  data ||= geocode_string(parts_of_name[1])
  data ||= geocode_string(parts_of_name[2])

  data
end

def geocode_string(query_string)
  query = {
    query: {
      q: query_string
    }
  }
  template = Addressable::Template.new(GEOCODE_TEMPLATE)
  uri = template.expand(query)
  data = JSON.parse(URI.open(uri).read)[0]

  data
end

places.each do |place|
  data = geocode(place[:name], place[:county])
  if data
    waypoint = {
      name: place[:name],
      sym: STATUS_ICONS[place[:state].to_sym],
      lat: data['lat'],
      lon: data['lon'],
      desc: data['display_name'],
    }
    gpx_file.waypoints << GPX::Waypoint.new(waypoint)

    puts format('✅ %<name>s', name: place[:name])
  else
    puts format('❌ %<name>s', name: place[:name])
  end

  sleep 2
end

gpx_file.write(OUTPUT_FILE)
