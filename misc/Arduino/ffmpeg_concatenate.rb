# Main code to transform large folders of TIFFs from MicroManager into a single MPGE File
# Also used to concatenate two such folders
# Use: drag-n-drop folder onto ffmpeg_concat.cmd file (in Windows)

def encode_movie(m)
	movie_path = m[0..(m.length-2)].join('\\')
	movie_folder = m[m.length-1]

	print movie_folder + ", path:" +movie_path+ "\n"

	movie_data_path = movie_path + "\\" + movie_folder + "\\Pos0\\"
	out_file = movie_data_path + "..\\" + movie_folder
	ffmpeg_cmd = "ffmpeg32 -framerate 30 -threads 2 -report -i \"#{movie_data_path}\\img_%09d_Default_000.tif\" -pix_fmt yuv420p \"#{out_file}.m4v\""
	print "#{ffmpeg_cmd}\n=>\n"
	`#{ffmpeg_cmd}`
	return [movie_path, "#{out_file}.m4v", movie_folder]
end

begin

	print "Some files were drag-and-dropped\n"
	print "\n"

	m1 = ARGV[0].split('\\')
	unless ARGV[1].nil?


		m2 = ARGV[1].split('\\')
		print "Will join #{m1[m1.length-1]} with #{m2[m2.length-1]}. That's OK? Y/n > \n"
		prompt = $stdin.gets.chomp
		unless prompt == "Y" or prompt == "" or prompt=="y"
			m1 = ARGV[1].split('\\')
			m2 = ARGV[0].split('\\')
			print "Will join #{m1[m1.length-1]} with #{m2[m2.length-1]}.\n"

		end


		# convert first folder
		print "Converting...\n\n"
		print "Converting first movie...\n"
		m1e = encode_movie(m1)
		# convert second folder
		print "Converting second movie...\n"
		m2e = encode_movie(m2)

		print "Concatenate these two: Y/n\n >"
		prompt = $stdin.gets.chomp
		if prompt =="Y" or prompt == "" or prompt =="y"
			# concatenate results
			print "Concatenating movies...\n"
			#concatenate_cmd = "Concatenate file #{m1e[1]} with #{m2e[1]} into #{m2e[0]}"
			concat_fname = m1e[2]+"_" + m2e[2] + ".m4v"
			temp_file = Time.now.to_i.to_s
			File.open(temp_file, "w+") {|f| f.write("file '#{m1e[1]}'\nfile '#{m2e[1]}'") }
			concatenate_cmd = "ffmpeg32 -f concat -safe 0 -i #{temp_file} -c copy \"#{concat_fname}\""
			`#{concatenate_cmd}`
			File.delete(temp_file)
		end

		print "All done. Goodbye.\n\n"
	else
		#single folder dropped
		print "Converting...\n\n"
		m1e = encode_movie(m1)
	end
rescue
  puts $!

end
