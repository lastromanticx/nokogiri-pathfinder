class NokogiriPathfinder::Handle
  attr_reader :nokogiri_html

  def initialize(url)
    html = open(url)
    @nokogiri_html = Nokogiri::HTML(html)
  end
end
