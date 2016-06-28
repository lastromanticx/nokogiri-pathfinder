class NokogiriPathfinder::CLI
  def welcome
    puts "/*/*/*/*/*/*\\*\\*\\*\\*\\*\\"
    puts "* NOKOGIRI PATHFINDER *"
    puts "\\*\\*\\*\\*\\*\\*/*/*/*/*/*/"
  end

  def get_input
    puts "Hi. Please enter URL:" 
    url = gets.strip
    while url == ""
      puts "Hmm..that URL seems to be blank, please enter a URL:"
      url = gets.strip
    end

    puts = "Thanks. Please enter a needle:"
    needle = gets.strip
    while needle == ""
      puts "Hmm..that needle seems to be empty, please enter a needle:"
      needle = gets.strip
    end

    [url, needle]
  end

  def process(url_needle_array)
    url,needle = url_needle_array
    query = NokogiriPathfinder::Query.new(url,needle)
    results = query.find

    puts "Thanks again! Here are your results:"
    results.each{|result| puts result.to_s}
  end

  def call
    welcome
    input = get_input
    process(input)
    puts "Goodbye, for now."
  end
end
