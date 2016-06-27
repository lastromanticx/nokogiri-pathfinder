require 'nokogiri'
require 'open-uri'
require 'uri'
require 'pry'

# test code for cli assessment
class SearchEngine
  def self.find(nokogiri_html,needle)
    needle_lower_case = needle.downcase
    # results
    node_paths = []
            # root node, node_path_string, classes_string
    stack = [[nokogiri_html.css('body')[0],".css('body')[0]",""]]

    until stack.empty? do
      curr,path,classes = stack.pop
      
      # if the class is 'text', check for a match
      if curr.class == Nokogiri::XML::Text
        if curr.text.downcase.match(needle_lower_case)
          node_paths << [path + ".text", classes]
        end

      # if the class is 'element', check for a match in attribute values,
      # save classes, and traverse the children
      elsif curr.class == Nokogiri::XML::Element
        class_str = curr.name + if curr.attribute("class") then "." + curr.attribute("class").value else "" end + "; "

        case curr.name
        when "a"
          if curr.attribute("href") and curr.attribute("href").value.downcase.match(needle_lower_case)
            node_paths << [path + ".attribute('href').value", classes + class_str]
          end

        when "img"
          if curr.attribute("src") and curr.attribute("src").value.downcase.match(needle_lower_case)
            node_paths << path + [".attribute('src').value", classes + class_str]
          end

          if curr.attribute("alt") and curr.attribute("alt").value.downcase.match(needle_lower_case)
            node_paths << path + [".attribute('alt').value", classes + class_str]
          end
        end

        (0..curr.children.size - 1).each do |i|
          _path = path + ".children[#{i}]"
          stack << [curr.children[i],_path,classes + class_str]
        end
      end
    end

    node_paths
  end
end

class Scraper
  def self.scrape_index_page(url)
    # :name index.css('.student-card h4').text
    # :location index.css('.student-card p').text
    # :profile_url index.css('.student-card a').attribute('href').value

    html = open(url)
    index = Nokogiri::HTML(html)
binding.pry
    cards = []

    index.css('div.student-card').each do |card|
      cards << {
        :name => card.css('h4').text,
        :location => card.css('p').text,
        :profile_url => "http://127.0.0.1:4000/" + card.css('a').attribute('href').value
      }
    end

    cards
  end

  # social profile.css('div.social-icon-container a')[INDEX].attribute('href').value
  # profile_quote profile.css('div.profile-quote').text
  # bio profile.css('div.bio-block p').text

  def self.scrape_profile_page(url)
    html = open(url)
    profile = Nokogiri::HTML(html)
    result = {}

    # get name
    name = profile.css('h1.profile-name').text.downcase.split(/\s+/)

    # get social links
    profile.css('div.social-icon-container a').each do |a|
      uri = URI.parse(a.attribute('href').value)
      key = /(www.)?[^.]+/.match(uri.hostname).to_s.gsub(/www\./,'')
      
      if (key).match(name[1]) then key = :blog end

      result[key.to_sym] = a.attribute('href').value
    end
 
    # get profile quote
    result[:profile_quote] = profile.css('div.profile-quote').text

    # get bio
    result[:bio] = profile.css('div.bio-block p').text

    result
  end
end

#Scraper.scrape_index_page('http://127.0.0.1:4000/fixtures/student-site/')
html = open('http://127.0.0.1:4000/fixtures/student-site/')
nokogiri_html = Nokogiri::HTML(html)
#puts(SearchEngine.find(nokogiri_html,"new york, ny")).to_s
puts(SearchEngine.find(nokogiri_html,"Glenelg, MD")).to_s
#puts(SearchEngine.find(nokogiri_html,"aaron enser")).to_s
