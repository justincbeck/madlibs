#!/usr/local/bin/ruby -w

module Madlibs
  class Engine
    def initialize(output)
      @output = output

      @libs = nil                                          # Initialize the file contents to nil
      @complete_sentences = Array.new                      # Where we'll store our modified sentences
      @value_map = Hash.new                                # Where we'll store named variables
    end
    
    def start
      select_lib
      construct_sentences
      display_output
    end
    
    def select_lib
      while @libs.nil? do                                  # As long as the selection is invalid, keep asking
        @output.puts "1. Gift Giving"                      # If 1 then use the Gift Giving file
        @output.puts "2. Lunch Hungers"                    # If 2 then use the Lunch Hungers file
        @output.puts "Select a Mad Lib by entering 1 or 2" # Ask for the selection
        selection = gets                                   # Get the selection from stdin
        
        case selection.chomp.to_i
        when 1
          @libs = IO.read("../data/Gift_Giving.madlib")    # Read in the file
        when 2
          @libs = IO.read("../data/Lunch_Hungers.madlib")  # Read in the file
        else
          @output.puts "Please make a choice by entering 1 or 2 and pressing enter."
        end
      end
    end
    
    def construct_sentences
      sentences = @libs.split('.')                        # Split on the periods

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

          if @value_map.has_key?(key)                     # If the value exists in the map
            value = @value_map[key]                       # Grab the value from the map
          else                                            # Otherwise
            puts "Enter " + key + " ('quit' to exit):"    # Ask for the value
            value = gets                                  # Get the value from stdin
            unless name.nil?                              # As long as name is not nil
              @value_map[name] = value                      # Put value in the map with name as it's key
              name = nil                                  # Reset name (we're done with it)
            end
          end

          Process.exit if value.chomp.eql?("quit")        # Exit if the value is 'quit'
          sentence = sentence.gsub(match, value.chomp)    # Substitute the part of speech for the users input
        }
        @complete_sentences << sentence + " "             # Collect the updated sentence
      }
    end
    
    def display_output
      @output.puts @complete_sentences                    # Show the finished product
    end
  end
end