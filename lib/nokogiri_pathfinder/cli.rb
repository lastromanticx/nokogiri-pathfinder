class NokogiriPathfinder::CLI
  def welcome
    puts "/*/*/*/*/*/*\\*\\*\\*\\*\\*\\"
    puts "* NOKOGIRI PATHFINDER *"
    puts "\\*\\*\\*\\*\\*\\*/*/*/*/*/*/"
  end

  def prompt
    puts "\nPlease enter a command (help, find, history, clear, exit):"
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
    
    while true
      prompt
      input = gets.strip

      case input
      when "help"
        puts "\nFIND - generates the node path and shortest"
        puts "Nokogiri::HTML CSS path to the search term."
        puts "\nHISTORY - lists this session's search history"
        puts "\nCLEAR - clears this session's history"
        puts "\nHELP - displays this message"

      when "find"
        url_needle = get_input
        process(url_needle)

      when "history"
        # to do

      when "exit"
        puts "\nGoodbye."
        break
  
      else
        puts "\nUnknown command. Please enter a command (type help for a list of commands):"
      end
    end
  end
end
