Gem::Specification.new do |s|
  s.name        = 'nokogiri-pathfinder'
  s.version     = '0.1.0'
  s.date        = '2016-06-30'
  s.summary     = "Finds CSS and Node Paths"
  s.description = "Yields attenuated class and node paths that can be used with Nokogiri's .css method to extract or iterate over the element containing the search term."
  s.authors     = ["Gilad Barkan"]
  s.email       = 'giladbarkan@live.com'
  s.files       = Dir['lib/   *.rb'] + Dir['bin/*']
  s.executables = ["nokogiri-pathfinder"]
  s.homepage    =
    'http://rubygems.org/gems/'
  s.license       = 'MIT'
end
