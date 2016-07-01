class NokogiriPathfinder::Query
  attr_reader :url, :nokogiri_html, :paths
  attr_accessor :search_term, :options

  @@all = []

  def self.all
    @@all
  end

  def self.clear
    self.all.clear
  end

  def initialize(args)
    @url = args[:url]
    @search_term = args[:search_term]
    @nokogiri_html = NokogiriPathfinder::Handle.new(args[:url]).nokogiri_html
    @options = args[:options]
    @paths = []
    self.class.all << self
  end

  def url=(url)
    @nokogiri_html = NokogiriPathfinder::Handle.new(url).nokogiri_html
  end

  def needle
    Regexp.new(Regexp.quote(@search_term),Regexp::IGNORECASE)
  end

  def find
            # root node, node_path_string, classes_string
    stack = [[@nokogiri_html.css('body')[0],".css('body')[0]",""]]

    until stack.empty? do
      curr,path,classes = stack.pop
      
      # if the class is 'text', check for a match
      if options[:text] and curr.class == NokogiriPathfinder::NOKOGIRI_XML_TEXT
        if needle.match(curr.text)
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

  def match_attributes(node)
    case node.name
    when "a"
      if options[:href] and node.attribute("href") and needle.match(node.attribute("href").value)
        ".attribute('href').value"
      end

    when "img"
      if options[:src] and node.attribute("src") and needle.match(node.attribute("src").value)
        "attribute('src').value"
      end

      if options[:alt] and node.attribute("alt") and needle.match(node.attribute("alt").value)
        ".attribute('alt').value"
      end
    end
  end

  def self.merge_node_paths(accumulator_path, path)
    left = ""
    middle1 = ""  # middles will store differing digits or commas
    middle2 = ""
    i = 0
    
    # get left part
    while accumulator_path[i] == path[i]
      left += path[i]
      i += 1
    end

    # find the start of the middle section
    i -=1
    
    while path[i].match(/\d/)
      i -= 1
      left = left[0..-2]
    end
    
    # get middle
    i += 1
    j = i

    while accumulator_path[i].match(/[0-9,]/)
      middle1 += accumulator_path[i]
      
      i += 1
    end
    
    while path[j].match(/\d/)
      middle2 += path[j]
      j += 1
    end
    
    # allow difference in one node only
    if accumulator_path[i..-1] != path[j..-1]
      false
    else
      left + middle1 + "," + middle2 + path[j..-1]
    end
  end

  private

  def attenuate
    # extract shortest css call
    if !@paths.empty?
      @paths.each.with_index do |path,i|  
        css_arr = path[:class_path].split(' ')
        shortest = css_arr.pop

        # check for object rather than string match
        while !@nokogiri_html.css(shortest).include?(path[:object])
          shortest = css_arr.pop + " " + shortest
        end

        @paths[i][:short] = shortest
      end
    end

    @paths
  end
end
