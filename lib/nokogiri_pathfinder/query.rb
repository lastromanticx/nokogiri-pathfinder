class NokogiriPathfinder::Query
  attr_reader :url, :nokogiri_html, :paths
  attr_accessor :search_term, :second_search_term, :options

  @@all = []

  def self.all
    @@all
  end

  def self.clear
    self.all.clear
  end

  def initialize(args)
    @search_term = args[:search_term]
    @second_search_term = args[:second_search_term]
    @nokogiri_html = NokogiriPathfinder::Handle.new(args[:url]).nokogiri_html
    @options = args[:options]
    @paths = []
    self.class.all << self

    # to do: handle file open error
  end

  def url=(url)
    @nokogiri_html = NokogiriPathfinder::Handle.new(url).nokogiri_html
  end

  def needle
    @search_term.downcase
  end

  def second_needle
    @second_search_term.downcase
  end

  def find
            # root node, node_path_string, classes_string
    stack = [[@nokogiri_html.css('body')[0],".css('body')[0]",""]]

    until stack.empty? do
      curr,path,classes = stack.pop
      
      # if the class is 'text', check for a match
      if options[:text] and curr.class == NokogiriPathfinder::NOKOGIRI_XML_TEXT
        if curr.text.downcase.match(needle)
          @paths << {:node_path => path + ".text", 
                     :class_path => classes,
                     :object => curr.parent}
        end

      # if the class is 'element', save class, check for
      # a match in attribute values, and traverse the children
      elsif curr.class == NokogiriPathfinder::NOKOGIRI_XML_ELEMENT
        class_str = curr.name + if curr.attribute("class") then "." + curr.attribute("class").value.match(/\S+/).to_s else "" end + " "

        matched_attribute = match_attributes(curr)
        if matched_attribute
          @paths << {:node_path => path + matched_attribute, 
                     :class_path => classes + class_str,
                     :object => curr}
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

        # check for object rather than string match
        while !@nokogiri_html.css(shortest).any?{|node| node == path[:object]}
          shortest = css_arr.pop + " " + shortest
        end

        @paths[i][:short] = shortest
      end
    end

    @paths
  end

  def match_attributes(node)
    case node.name
    when "a"
      if options[:href] and node.attribute("href") and node.attribute("href").value.downcase.match(needle)
        ".attribute('href').value"
      end

    when "img"
      if options[:src] and node.attribute("src") and node.attribute("src").value.downcase.match(needle)
        "attribute('src').value"
      end

      if options[:alt] and node.attribute("alt") and node.attribute("alt").value.downcase.match(needle)
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
