require 'tecplot_loader.rb'

loader = TecplotLoader.new()
read_plots = loader.load_tec('sample.tec')

read_plots.each { |plot|
  puts plot.title
  puts plot.variables
  puts plot.zone
}