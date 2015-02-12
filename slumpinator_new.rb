require 'date'

@undo = ["undo","back","tillbaka","bak"] #list of "undo"-commands for "närvaro"-funktion
@nej = ["nej","n","no"] #list of "no"-answers for "närvaro"-funktion

def närvaro(klass_lista)
  elever = {}
  i = 0
  while i < klass_lista.length
    puts "Är #{klass_lista[i].chomp} här?"
    input = gets.chomp.downcase
    if @undo.include? input
      i -= 2
    elsif @nej.include? input
      elever[klass_lista[i].chomp] = "frånvarande"
      print "#{klass_lista[i].chomp}"
      puts ' är "sjuk".'
    elsif input.to_i > 0
      elever[klass_lista[i].chomp] = "#{input.to_i} min sen"
      puts "#{klass_lista[i].chomp} kom #{input.to_i} minuter sen."
    else
      elever[klass_lista[i].chomp] = "närvarande"
      puts "#{klass_lista[i].chomp} är här."
    end
    i += 1
  end
  return elever
end

def närvarande_elever_lista(dict)
  närvarande_elever = []
  dict.each_pair do |key, value|
    if value != "frånvarande"
      närvarande_elever << key
    end
  end
  return närvarande_elever
end

def group_picker(array, group_size)
  shuffled_list = array.shuffle
  groups = []
  groups << shuffled_list.pop(group_size) until shuffled_list.empty?
  return groups
end

def write_unless_file_exist_in_folder(folder,lists)
  puts "vad ska dokumentet heta?"
  if File.exist?("#{folder}/#{file = gets.chomp}.txt")
    puts "#{file} finns redan"
    puts "vill du skriva över filen?"
    if gets.chomp == "ja"
      dokument = File.open("#{folder}/#{file}.txt", "w")
      lists.each do |group|
        dokument.puts group * " & "
      end
      dokument.close
    else
      puts "försök igen."
      write_unless_file_exist_in_folder(folder,lists)
    end
  else
    dokument = File.open("#{folder}/#{file}.txt", "w")
    lists.each do |group|
      dokument.puts group * " & "
    end
    dokument.close
  end
end

#fetches a list of class_lists from /klass_listor
klass_listor = []
Dir.entries('klass_listor').drop(2).each_with_index { |klass, index| klass_listor[index] = klass.sub(".txt","") } #.drop(2) to not include "." and ".." Dir
#end of comment block

puts "vilken klass?" #asks you to choose a class
puts "Klasser:"
klass_listor.each_with_index { |klass, nr| puts "#{nr+1}. #{klass}" } #puts all classes in klass_listor
vald_klass = gets.chomp #vald_klass should be name of class or number assosiatet with chosen class


until klass_listor.include?(vald_klass) #check if chosen class is a valid choise
  if vald_klass.to_i > 0 && klass_listor.length >= vald_klass.to_i #if vald_klass is a number
    vald_klass = klass_listor[vald_klass.to_i - 1]
  else
    puts "Klass #{vald_klass} finns tyvärr inte"
    puts "Försök igen."
    vald_klass = gets.chomp
  end
end

puts "Klass: #{vald_klass}"
närvaro_dict = närvaro(open("klass_listor/#{vald_klass}.txt").readlines)

puts "vill du göra grupper?"
if gets.chomp.downcase == "ja"
  puts "Hur många elever per grupp?"
  group_size = gets.to_i
  groups = group_picker(närvarande_elever_lista(närvaro_dict), group_size)
  groups.each do |group|
    puts group * " & "
  end
  puts "vill du spara grupperna i ett dokument?"
  if gets.chomp.downcase == "ja"
    write_unless_file_exist_in_folder("grupper", groups)
  end
end

Dir.chdir("närvaro") do
  unless Dir.exist?(vald_klass)
    Dir.mkdir(vald_klass)
  end
  frånvaro_och_förseningar = File.open("#{vald_klass}/#{Date.today}.csv", "w")
  närvaro_dict.each do |key, value|
    frånvaro_och_förseningar.puts "#{key}: #{value}"
  end
  frånvaro_och_förseningar.close
end