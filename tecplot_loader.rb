class Tecplot

  attr_accessor :title
  attr_accessor :variables
  attr_accessor :zone
  attr_accessor :values

  def initialize
    @title = ""
    @variables = Array.new
    @values = Array.new
    @zone = ""
  end

end

class TecplotLoader

  def initialize

  end

  def load_tec(*args)
    File.open("sample.tec", "r") { |file|

      plots = Array.new
      plot = nil

      while line = file.gets

        if line =~ /TITLE/  # TITLE tag
          plot = Tecplot.new
          title_val = /"[^"]+"/.match(line)  # Value of the title
          plot.title = title_val[0].gsub(/"/, '') # Remove quotes
          puts "Title found: " + plot.title

          plots.push plot

        elsif line =~ /VARIABLES/  # VARIABLES tag
          variable_matches = line.scan(/"[^"]+"/)
          # For each variable remove quotes and push to array
          variable_matches.to_a.each_with_index { |variable_string, i|
            plot.variables.push variable_string.gsub(/"/, '')
            plot.values[i] = Array.new
          }

        elsif line =~ /ZONE/  # ZONE tag
          zone_val = /"[^"]+"/.match(line)  # Value of the zone
          plot.zone = zone_val[0].gsub(/"/, '') # Remove quotes

        # Matches floating numbers in scientific notation
        elsif line =~ /^[-+]?[0-9]+\.[0-9]+[eE][-+]?[0-9]+/
          vals = line.split(" ")
          vals.each_with_index { |val, i|
            plot.values[i].push val.to_f
          }
        end
      end

      return plots
    }
  end
end