####### Students: Kim Thai, Marilyn Salvatierra(U71917588)

# Extracts just the definitions from the grammar file
# Returns an array of strings where each string is the lines for
# a given definition (without the braces)
def read_grammar_defs(filename)
  filename = 'grammars/' + filename unless filename.start_with? 'grammars/'
  filename += '.g' unless filename.end_with? '.g'
  contents = open(filename, 'r') { |f| f.read }
  contents.scan(/\{(.+?)\}/m).map do |rule_array|
    rule_array[0]
  end
end


# Takes data as returned by read_grammar_defs and reformats it
# in the form of an array with the first element being the
# non-terminal and the other elements being the productions for
# that non-terminal.
# Remember that a production can be empty (see third example)
# Example:
#   split_definition "\n<start>\nYou <adj> <name> . ;\nMay <curse> . ;\n"
#     returns ["<start>", "You <adj> <name> .", "May <curse> ."]
#   split_definition "\n<start>\nYou <adj> <name> . ;\n;\n"
#     returns ["<start>", "You <adj> <name> .", ""]
def split_definition(raw_def)
  raw_def.split(/\s*\n{1}/)[1..-1].map{|a| a.gsub(/\s+/,' ').gsub(/\s*;/, '')}
end

# Takes an array of definitions where the definitions have been
# processed by split_definition and returns a Hash that
# is the grammar where the key values are the non-terminals
# for a rule and the values are arrays of arrays containing
# the productions (each production is a separate sub-array)
# Example:
# to_grammar_hash([["<start>", "The   <object>   <verb>   tonight."], ["<object>", "waves", "big    yellow       flowers", "slugs"], ["<verb>", "sigh <adverb>", "portend like <object>", "die <adverb>"], ["<adverb>", "warily", "grumpily"]])
# returns {"<start>"=>[["The", "<object>", "<verb>", "tonight."]], "<object>"=>[["waves"], ["big", "yellow", "flowers"], ["slugs"]], "<verb>"=>[["sigh", "<adverb>"], ["portend", "like", "<object>"], ["die", "<adverb>"]], "<adverb>"=>[["warily"], ["grumpily"]]}
def to_grammar_hash(split_def_array)
  h = Hash.new
  split_def_array.each{|v| h[v[0]] = v[1..-1].map{|g| g.split(/\s/)}}
  return h
end


# Returns true iff s is a non-terminal
# a.k.a. a string where the first character is <
#        and the last character is >
def is_non_terminal?(s)
  s[0] == "<" && s[-1] == ">"
end

# Given a grammar hash (as returned by to_grammar_hash)
# returns a string that is a randomly generated sentence from
# that grammar
#
# Once the grammar is loaded up, begin with the <start> production and expand it to generate a
# random sentence.
# Note that the algorithm to traverse the data structure and
# return the terminals is extremely recursive.
#
# The grammar will always contain a <start> non-terminal to begin the
# expansion. It will not necessarily be the first definition in the file,
# but it will always be defined eventually. Your code can
# assume that the grammar files are syntactically correct
# (i.e. have a start definition, have the correct  punctuation and format
# as described above, don't have some sort of endless recursive cycle in the
# expansion, etc.). The names of non-terminals should be considered
# case-insensitively, <NOUN> matches <Noun> and <noun>, for example.
def expand(grammar, non_term="<start>")
  s = ""
  arr = grammar.fetch(non_term, []).sample      #Choose a random element from the array.

  if arr != nil
    arr.each do |x|
      if !is_non_terminal?(x)
        s = s + x + " "
      elsif is_non_terminal?(x)
        s = s + expand(grammar, x)
      end
    end
  end
  s.gsub(/\s(?=\.)|\s(?=,)|\s(?=\^)|(?<=\^)\s|\s(?=\?)|\s(?=!)|(?<=\()\s|\s(?=\))|\s(?=:)/, '')
end

# Given the name of a grammar file,
# read the grammar file and print a
# random expansion of the grammar
def rsg(file_name)
  # TODO: your implementation here
  arr = read_grammar_defs file_name
  new_arr = arr.map{|s| split_definition s}

  arr_hash = to_grammar_hash new_arr
  puts expand arr_hash
end

if __FILE__ == $0
  # prompt the user for the name of a grammar file
  # rsg that file

  puts "enter file name: "
  file_name = gets.strip
  rsg file_name
end