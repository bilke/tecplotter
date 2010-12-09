require 'tecplot_loader.rb'

require 'tecplotter.rb'

Tecplotter.new(read_plots)

read_plots.each { |plot|
  puts plot.title
  puts plot.variables
  puts plot.zone
}