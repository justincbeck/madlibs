#!/usr/local/bin/ruby -w

libs = nil                                          # Initialize the file contents to nil
completeSentences = Array.new                       # Where we'll store our modified sentences
valueMap = Hash.new                                 # Where we'll store named variables

while libs.nil? do                                  # As long as the selection is invalid, keep asking
  puts "1. Gift Giving"                             # If 1 then use the Gift Giving file
  puts "2. Lunch Hungers"                           # If 2 then use the Lunch Hungers file
  puts "Select a Mad Lib by entering 1 or 2"        # Ask for the selection
  selection = gets                                  # Get the selection from stdin

  if selection.chomp.eql?("1")
    libs = IO.read("../data/Gift_Giving.madlib")    # Read in the file
  elsif selection.chomp.eql?("2")
    libs = IO.read("../data/Lunch_Hungers.madlib")  # Read in the file
  end
end

sentences = libs.split('.')                         # Split on the periods

sentences.each { |it|
  sentence = (it + '.').strip.gsub(/\r?\n/, " ")    # Seperate out the sentences in to an iteration
  value = nil                                       # That which the user will enter
  name = nil                                        # The name of the variable we'll store (if there is one)
  key = nil                                         # The piece of "language" we're looking for
  
  sentence.scan(/\(\((?>\w+\s?|:)+\)\)/) { |match|  # Match the whole replacable part
    variable = match.scan(/(?>\w+\s?|:)+/)[0]       # Drop the parentheses
    parts = variable.split(':')                     # Split on the colon

    if parts.size.eql?(2)                           # We have a named variable
      name = parts[0]                               # Set 'name' to the variable name
      key = parts[1]                                # Set 'key' to the part of speech we're interested in
    else                                            # We don't have named variable
      key = variable                                # Set 'key' to the part of speech
    end

    parts = nil                                     # Reset parts (we're done with it)
    
    if valueMap.has_key?(key)                       # If the value exists in the map
      value = valueMap[key]                         # Grab the value from the map
    else                                            # Otherwise
      puts "Enter " + key + " ('quit' to exit):"    # Ask for the value
      value = gets                                  # Get the value from stdin
      unless name.nil?                              # As long as name is not nil
        valueMap[name] = value                      # Put value in the map with name as it's key
        name = nil                                  # Reset name (we're done with it)
      end
    end

    Process.exit if value.chomp.eql?("quit")        # Exit if the value is 'quit'
    sentence = sentence.gsub(match, value.chomp)    # Substitute the part of speech for the users input
  }
  completeSentences << sentence + " "               # Collect the updated sentence
}

puts completeSentences                              # Show the finished product