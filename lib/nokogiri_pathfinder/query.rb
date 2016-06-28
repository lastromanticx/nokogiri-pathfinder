require 'nokogiri'
require 'open-uri'
require 'uri'
require 'pry'

class NokogiriPathfinder::Query
  attr_reader :url, :nokogiri_html
  attr_accessor :needle, :second_needle

  def initialize(url,needle,second_needle=nil)
    @needle = needle
    @second_needle = second_needle
    @nokogiri_html = NokogiriPathfinder::Handle.new(url).nokogiri_html
  end

  def url=(url)
    @nokogiri_html = NokogiriPathfinder::Handle.new(url).nokogiri_html
  end

  def find
    needle_lower_case = needle.downcase
    # results
    node_paths = []
            # root node, node_path_string, classes_string
    stack = [[@nokogiri_html.css('body')[0],".css('body')[0]",""]]

    until stack.empty? do
      curr,path,classes = stack.pop
      
      # if the class is 'text', check for a match
      if curr.class == Nokogiri::XML::Text
        if curr.text.downcase.match(needle_lower_case)
          node_paths << [path + ".text", classes]
        end

      # if the class is 'element', save class, check for
      # a match in attribute values, and traverse the children
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

      while !nokogiri_html.css(shortest).any? {|node| node.text.downcase.match(needle_lower_case) or match_attributes(node, needle_lower_case)}
        shortest = css_arr.pop + shortest
      end
    end 

    node_paths << shortest
    node_paths
  end

  private

  def match_attributes(node,needle_lower_case)
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
end

class NokogiriPathfinder::Handle
  attr_reader :nokogiri_html

  def initialize(url)
    html = open(url)
    @nokogiri_html = Nokogiri::HTML(html)
  end
end
