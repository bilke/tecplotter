
bench_dirs = [ 'dir1/', 'dir2/' ]
benchmark_dir = 'new/'
reference_dir = 'ref/'
pdflatex_dir = '/usr/texbin'

# Cleanup from previous runs
Dir.glob("./*.pdf") do |file|
  File.delete(file)
end

# Iterate over failed benchmark directories
bench_dirs.each do |bench_dir|
  next if not File.directory?(benchmark_dir + bench_dir)
  # Search for .tec files
  Dir.glob(benchmark_dir + bench_dir + '*.tec') do |new_tecfile|

    # Check for reference tecfile
    if File.exists?(new_tecfile.gsub(benchmark_dir, reference_dir))
      ref_tecfile = new_tecfile.gsub(benchmark_dir, reference_dir)

      # Create input file for tioga
      tioga_input_file = File.read('tioga_main_template.rb')
      tioga_input_file.gsub!('$ref_tecfile$', ref_tecfile)
      tioga_input_file.gsub!('$new_tecfile$', new_tecfile)

      output_filename = new_tecfile.gsub(benchmark_dir, "").gsub(/\//, "_")
      tioga_input_filename = "#{output_filename}.rb"
      File.open(tioga_input_filename, "w") do |file|
        file.puts tioga_input_file
      end

      # Run tioga
      %x[export PATH=#{pdflatex_dir}:$PATH && /usr/local/bin/tioga #{tioga_input_filename} -p]

      # Delete tioga input file
      File.delete(tioga_input_filename)

      portfolio_filename = output_filename + "_portfolio.pdf"
      if File.exists?(portfolio_filename)
        # Rename plot files
        File.rename(portfolio_filename, portfolio_filename.gsub("_portfolio", ""))

        # Output
        puts "SUCCESS: Plot written to #{portfolio_filename.gsub("_portfolio", "")}"
      else
        puts "ERROR: Something went wrong when running tioga! No plot file was written."
      end

    else
      # If not exists goto next tecfile
      puts "ERROR: Reference file #{new_tecfile.gsub(benchmark_dir, reference_dir)} missing!"
      next
    end


  end
end

# Delete intermediate plot files ending in plot.pdf
Dir.glob("./*plot.pdf") do |file|
  File.delete(file)
end