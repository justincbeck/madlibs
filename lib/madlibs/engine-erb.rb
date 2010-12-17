#!/usr/local/bin/ruby -w

require "erb"

# storage for the keyed questions reuse
$answers = Hash.new

# asks a madlib question and returns the answer
def q_to_a(question)
  question.gsub!(/\s+/, " ")
  
  if $answers.include? question
    $answers[question]
  else
    key = if question.sub!(/^\s*(.+?)\s*:\s*/, "") then $1 else nil end
      
    print "Give me #{question}: "
    answer = $stdin.gets.chomp
    
    $answers[key] = answer unless key.nil?
    
    answer
  end
end

# usage
unless ARGV.size == 1 and test(?e, ARGV[0])
  puts "Usage: #{File.basename($PROGRAM_NAME)} MADLIB_FILE"
  exit
end

# load MadLib, with title
madlib = "\n#{File.basename(ARGV.first, '.madlib').tr('_', ' ')}\n\n" + File.read(ARGV.first)
# convert ((...)) to <%= q_to_a('...') %>
madlib.gsub!(/\(\(\s*(.+?)\s*\)\)/, "<%= q_to_a('\\1') %>")
# run template
ERB.new(madlib).run