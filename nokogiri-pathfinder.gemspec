# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nokogiri_pathfinder/version'

Gem::Specification.new do |s|
  s.name        = 'nokogiri-pathfinder'
  s.version     = '0.1.0'
  s.date        = '2016-06-30'
  s.summary     = "Finds CSS and Node Paths"
  s.description = "Yields attenuated class and node paths that can be used with Nokogiri's .css method to extract or iterate over the element containing the search term."
  s.version     = NokogiriPathfinder::VERSION
  s.authors     = ["Gilad Barkan"]
  s.email       = 'giladbarkan@live.com'
  s.files       = `git ls-files`.split($\)
  s.executables << "nokogiri-pathfinder"
  s.license       = 'MIT'
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "open-uri"
  s.add_development_dependency "pry"
end
