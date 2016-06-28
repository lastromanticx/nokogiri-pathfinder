require 'open-uri'
require 'pry'
require 'nokogiri'

require_relative "nokogiri_pathfinder/version"
require_relative "nokogiri_pathfinder/cli"
require_relative "nokogiri_pathfinder/query"

module NokogiriPathfinder
end

url = 'http://127.0.0.1:4000/fixtures/student-site/'
query = NokogiriPathfinder::Query.new(url,"Glenelg, MD")
puts query.find

