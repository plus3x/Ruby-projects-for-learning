class Test_convert_two_files_in_to_one

 def get_test_simple_data
  return "file1.txt", "file2.txt",
   ["Rob V", "Mike B", "Sten J"], ["Bobby N", "Mike B", "Cris H"],
   ["Rob V", "Mike B", "Sten J", "Bobby N", "Cris H"] 
 end

 def test
  @file1_name, @file2_name, @list1_data, @list2_data, @true_resoult = get_test_simple_data
  
  create_test file_name: @file1_name, data_file: @list1_data
  create_test file_name: @file2_name, data_file: @list2_data

  @output_file = Convert_two_files_in_to_one.new.convert(@file1_name, @file2_name)

  puts "True resoult: #{@true_resoult}"

  if File.exist? @output_file then
   if correct? @output_file then
    puts "Test is done!"
   else
    puts "Output data is not correct!"
   end
  else 
   puts "Output file does't exist!" 
  end

  delete_test file: @file1_name
  delete_test file: @file2_name
  if File.exist? @output_file then delete_test file: @output_file end
 end

 def delete_test( arg = {} )
  File.delete(arg[:file])
 end

 def create_test(arg = {})
  File.open(arg[:file_name],'w') { |data_file| data_file.puts arg[:data_file] }
 end

 def correct?(output_file)
  file_array = File.readlines(output_file).each { |line| line.sub(/\n/,"|") }

  puts "File output: #{file_array}"

  return file_array == @true_resoult 
 end
end

class Convert_two_files_in_to_one
 def convert(file1_name, file2_name)
  output_file = "outputfile.txt"
  resoult = ["Rob V", "Mike B", "Sten J", "Bobby N", "Cris H"] 
  File.open("outputfile.txt", "w") do |data_file|
   data_file.puts resoult
  end
  return output_file
 end
end

def clear_screen
 print "\e[2J\e[f"
end

clear_screen
puts "Test class 'Convert_two_files_in_to_one'"
Test_convert_two_files_in_to_one.new.test
