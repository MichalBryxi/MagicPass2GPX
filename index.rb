require 'nokogiri'
require 'open-uri'
require 'addressable/template'
require 'json'

LIST_URL = 'https://www.magicpass.ch/en/stations'
GEOCODE_TEMPLATE = 'https://geocode.maps.co/search/{?query*}'

list_page = Nokogiri::HTML.parse(URI.open(LIST_URL))
list_links = list_page.search('.rounded-aio-block.overflow-hidden.group.border.relative')
list_titles = list_links.map { |item| item['title'] }

list_titles.each do |title|
  template = Addressable::Template.new(GEOCODE_TEMPLATE)
  uri = template.expand({
    'query' => {
      'q' => title,
    }
  })
  json = JSON.load(URI.open(uri))
  puts json
  exit
end