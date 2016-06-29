class NokogiriPathfinder::CLI
  def welcome
    puts "/*/*/*/*/*/*\\*\\*\\*\\*\\*\\"
    puts "* NOKOGIRI PATHFINDER *"
    puts "\\*\\*\\*\\*\\*\\*/*/*/*/*/*/"
  end

  def get_input
    puts "\nPlease enter URL:" 
    url = gets.strip
    while url == ""
      puts "\nHmm..that URL seems to be blank, please enter a URL:"
      url = gets.strip
    end

    puts "\nPlease enter a needle:"
    needle = gets.strip
    while needle == ""
      puts "\nHmm..that needle seems to be empty, please enter a needle:"
      needle = gets.strip
    end

    [url, needle]
  end

  def process(url_needle_array)
    url,needle = url_needle_array
    query = NokogiriPathfinder::Query.new(url,needle)
    results = query.find

    puts "\nResults:"
    results.each{|result| puts "\n" + result.to_s}
  end

  def call
    welcome
    input = get_input
    process(input)
    puts "\nGoodbye, for now."
  end
end
