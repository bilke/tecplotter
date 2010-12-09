require 'rubygems'
require 'Tioga/FigureMaker'
require 'tecplot_loader.rb'

class Tecplotter

  include Tioga
  include FigureConstants

  attr_reader :t  # t is to talk to tioga

  def initialize()
    @t = FigureMaker.default

    @margin = 0.025
    
    loader = TecplotLoader.new
    plots = loader.load_tec("sample.tec")

    plots.each { |plot|
      t.def_figure(plot.title) { exec_plot(plot) }
    }
  end

  # function for automatically computing graph boundaries
  def plot_boundaries(xs,ys,margin,xmin=nil,xmax=nil,ymin=nil,ymax=nil)
    xmin = xs.min if xmin == nil
    xmax = xs.max if xmax == nil
    ymin = ys.min if ymin == nil
    ymax = ys.max if ymax == nil

    width = (xmax == xmin) ? 1 : xmax - xmin
    height = (ymax == ymin) ? 1 : ymax - ymin

    left_boundary = xmin - margin * width
    right_boundary = xmax + margin * width

    top_boundary = ymax + margin * height
    bottom_boundary = ymin - margin * height

    return [ left_boundary, right_boundary, top_boundary, bottom_boundary ]
  end

  def exec_plot(plot)

    row_margin = 0.15
    t.rescale(0.5)

    plot.variables.each_with_index { |var, i|
      if i > 0
        xs = plot.values[0]
        ys = plot.values[i]
        t.subplot(t.row_margins(
            'num_rows' => plot.variables.size - 1, 'row' => i,
            'row_margin' => row_margin)) {
          t.do_box_labels(plot.zone, plot.variables[0], plot.variables[i])
          t.show_plot(plot_boundaries(xs,ys,@margin)) {
            t.show_polyline(xs,ys,Red)
          }
        }
      end
    }
  end
end

Tecplotter.new