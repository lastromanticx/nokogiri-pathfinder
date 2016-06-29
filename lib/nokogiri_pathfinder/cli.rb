class NokogiriPathfinder::CLI
  def welcome
    puts "/*/*/*/*/*/*\\*\\*\\*\\*\\*\\"
    puts "* NOKOGIRI PATHFINDER *"
    puts "\\*\\*\\*\\*\\*\\*/*/*/*/*/*/"
  end

  def prompt
    puts "\nPlease enter a command (help, find, history, clear, pry, exit):"
  end
 
  def get_input
    puts "\nPlease enter URL:" 
    url = gets.strip
    while url == ""
      puts "\nHmm..that URL seems to be blank, please enter a URL:"
      url = gets.strip
    end

    puts "\nPlease enter a search term:"
    search_term = gets.strip
    while search_term == ""
      puts "\nHmm..that needle seems to be empty, please enter a needle:"
      search_term = gets.strip
    end

    puts "\nPlease enter a second search term (or press return to leave blank:)"
    second_search_term = gets.strip

    puts "\nPlease enter options separated by commas (text, href, alt, and/or src). Blank or unlisted will default to text:"
    options = gets.strip
    options_hash = {:text => false, 
                    :href => false, 
                    :src => false, 
                    :alt => false}

    if options == "" then options_hash[:text] = true end

    options.split(/\s*,\s*/).each_with_object(options_hash){|option,hash| hash[option.to_sym] = true}

    {:url => url, 
     :search_term => search_term,
     :second_search_term => second_search_term,
     :options => options_hash}
  end

  def process(search_arguments)
    query = NokogiriPathfinder::Query.new(search_arguments)
    results = query.find

    puts "\nResults:"
    results.each{|result| puts "\n" + result.to_s}
  end

  def call
    welcome
    
    while true
      prompt
      input = gets.strip.downcase

      case input
      when "help"
        puts "\nFIND - generates the node path and shortest"
        puts "Nokogiri::HTML CSS path to the search term."
        puts "\nHISTORY - lists this session's search history"
        puts "\nCLEAR - clears this session's history"
        puts "\nPRY - starts Pry"
        puts "\nHELP - displays this message"

      when "find"
        url_needle = get_input
        process(url_needle)

      when "history"
        if NokogiriPathfinder::Query.all.empty?
          puts "\nHistory is empty"
        else     
          NokogiriPathfinder::Query.all.each.with_index(1) do |search,i|
            puts "\n#{i}. Search-Term: #{search.search_term}"
          end
        end

      when "clear"
        puts "Are you sure you want to clear the history? Type (yes/no)"
        answer = ""
        until answer == "yes" or answer == "no"
          answer = gets.strip
        end

        if answer =="yes"
          NokogiriPathfinder::Query.clear
          puts "\nCleared history."
        else
          puts "Action cancelled."
        end

      when "pry"
        Pry.start

      when "exit"
        puts "\nGoodbye."
        break
  
      else
        puts "\nUnknown command. Please enter a command (type help for a list of commands):"
      end
    end
  end
end
