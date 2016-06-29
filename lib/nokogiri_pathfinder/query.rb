require 'nokogiri'
require 'open-uri'
require 'uri'
require 'pry'

class NokogiriPathfinder::Query
  attr_reader :url, :search_term, :nokogiri_html, :paths
  attr_accessor :needle, :second_needle

  @@all

  def self.all
    @@all
  end

  def initialize(url,needle,second_needle=nil)
    @search_term = needle
    @needle = needle.downcase
    @second_needle = second_needle
    @nokogiri_html = NokogiriPathfinder::Handle.new(url).nokogiri_html
    @paths = []
  end

  def url=(url)
    @nokogiri_html = NokogiriPathfinder::Handle.new(url).nokogiri_html
  end

  def find
            # root node, node_path_string, classes_string
    stack = [[@nokogiri_html.css('body')[0],".css('body')[0]",""]]

    until stack.empty? do
      curr,path,classes = stack.pop
      
      # if the class is 'text', check for a match
      if curr.class == Nokogiri::XML::Text
        if curr.text.downcase.match(@needle)
          @paths << {:node_path => path + ".text", 
                     :class_path => classes}
        end

      # if the class is 'element', save class, check for
      # a match in attribute values, and traverse the children
      elsif curr.class == Nokogiri::XML::Element
        class_str = curr.name + if curr.attribute("class") then "." + curr.attribute("class").value.match(/\S+/).to_s else "" end + " "

        matched_attribute = match_attributes(curr)
        if matched_attribute
          @paths << {:node_path => path + matched_attribute, 
                     :class_path => classes + class_str}
        end

        (0..curr.children.size - 1).each do |i|
          _path = path + ".children[#{i}]"
          stack << [curr.children[i],_path,classes + class_str]
        end
      end
    end

    attenuate
  end

  private

  def attenuate
    # extract shortest css call
    if !@paths.empty?
      @paths.each.with_index do |path,i|  
        css_arr = path[:class_path].split(' ')
        shortest = css_arr.pop

        while !@nokogiri_html.css(shortest).any? {|node| node.text.downcase.match(@needle) or match_attributes(node)}
          shortest = css_arr.pop + shortest
        end

        @paths[i][:short] = shortest
      end
    end

    @paths
  end

  def match_attributes(node)
    case node.name
    when "a"
      if node.attribute("href") and node.attribute("href").value.downcase.match(@needle)
        ".attribute('href').value"
      end

    when "img"
      if node.attribute("src") and node.attribute("src").value.downcase.match(@needle)
        "attribute('src').value"
      end

      if node.attribute("alt") and node.attribute("alt").value.downcase.match(@needle)
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
