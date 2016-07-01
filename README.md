NOKOGIRI PATHFINDER

Nokogiri Pathfinder is a command line tool to easily locate the proper Nokogiri .CSS path that contains the text you are interested in. Rather than, or along with, using a web browser's inspector, simply enter the url and search term, and Nokogiri Pathfinder will traverse the Nokogiri tree to find the shortest .CSS path to the node.


INSTALLATION

Dependencies: open-uri, nokogiri, pry

1. Clone this repository:
git clone https://github.com/lastromanticx/nokogiri-pathfinder

2. Move into the gem's directory:
cd nokogiri-pathfinder

4. Build:
gem build nokogiri-pathfinder.gemspec

5. Install:
gem install nokogiri-pathfinder-0.1.0.gem

5. To run the CLI from a terminal after installation, type:
nokogiri-pathfinder


INSTRUCTIONS

The pathfinder is very simple:

Input a valid URL

Input a search string

Input options separated by commas (default is text)
Options describe which nodes will be tested for a match:
  text, href, alt, and/or src; or all for all
