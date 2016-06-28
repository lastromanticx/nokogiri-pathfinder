require 'nokogiri'
require 'open-uri'
require 'uri'
require 'pry'

# test code for cli assessment
class SearchEngine
  def self.match_attributes(node,needle_lower_case)
    case node.name
    when "a"
      if node.attribute("href") and node.attribute("href").value.downcase.match(needle_lower_case)
        ".attribute('href').value"
      end

    when "img"
      if node.attribute("src") and node.attribute("src").value.downcase.match(needle_lower_case)
        "attribute('src').value"
      end

      if node.attribute("alt") and node.attribute("alt").value.downcase.match(needle_lower_case)
        ".attribute('alt').value"
      end
    end
  end

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
        class_str = curr.name + if curr.attribute("class") then "." + curr.attribute("class").value.match(/\S+/).to_s else "" end + " "

        matched_attribute = match_attributes(curr, needle_lower_case)
        if matched_attribute
          node_paths << [path + matched_attribute,classes + class_str]
        end

        (0..curr.children.size - 1).each do |i|
          _path = path + ".children[#{i}]"
          stack << [curr.children[i],_path,classes + class_str]
        end
      end
    end

    # extract shortest css call
    if !node_paths.empty?
      css_arr = node_paths[0][1].split(' ')
      shortest = css_arr.pop

      while !nokogiri_html.css(shortest).any? { 
              |node| node.text.downcase.match(needle_lower_case) or (node.attribute("href") and node.attribute("href").value.downcase.match(needle_lower_case)) or (node.attribute("src") and node.attribute("src").value.downcase.match(needle_lower_case)) or (node.attribute("alt") and node.attribute("alt").value.downcase.match(needle_lower_case))
            }
      
        shortest = css_arr.pop + shortest
      end
    end 

    node_paths << shortest
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
end

#Scraper.scrape_index_page('http://127.0.0.1:4000/fixtures/student-site/')
html = open('http://127.0.0.1:4000/fixtures/student-site/')
nokogiri_html = Nokogiri::HTML(html)
#puts(SearchEngine.find(nokogiri_html,"new york, ny")).to_s
puts(SearchEngine.find(nokogiri_html,"Glenelg, MD")).to_s
#puts(SearchEngine.find(nokogiri_html,"aaron enser")).to_s
