require 'rubygems'
require 'Tioga/FigureMaker'
require 'tecplot_loader.rb'

class Tecplotter

  include Tioga
  include FigureConstants

  attr_reader :t  # t is to talk to tioga

  def initialize(plots)
    @t = FigureMaker.default
    @margin = 0.025

    plots.each do |plot|
      t.def_figure(plot.title) { exec_plot(plot) }
    end

  end

  # function for automatically computing graph boundaries
  def plot_boundaries(xs,ys,margin)
    xmin = xs.min
    xmax = xs.max
    ymin = ys.min
    ymax = ys.max

    width = (xmax == xmin) ? 1 : xmax - xmin
    height = (ymax == ymin) ? 1 : ymax - ymin

    left_boundary = xmin - margin * width
    right_boundary = xmax + margin * width

    top_boundary = ymax + margin * height
    bottom_boundary = ymin - margin * height

    return [ left_boundary, right_boundary, top_boundary, bottom_boundary ]
  end
  
  def setup_lines(xs, yarry)

    ymin = yarry[0].min
    ymax = yarry[0].max
    yarry.each do |values|
      ymin = values.min if values.min < ymin
      ymax = values.max if values.max > ymax
    end
    margin = 0.1
    num_lines = yarry.length
    return nil unless num_lines > 0
    xmin = xs.min
    xmax = xs.max
    width = (xmax == xmin)? 1 : xmax - xmin
    height = (ymax == ymin)? 1 : ymax - ymin
    return [ xmin - margin * width, xmax + margin * width,
             ymax + margin * height, ymin - margin * height ]
  end

  def exec_plot(plot)

    row_margin = 0.15
    t.rescale(0.5)

    plot.variables.each_with_index do |var, i|
      if i > 0
        xs = plot.values[0]
        ys = plot.values[i]
        t.subplot(t.row_margins(
            'num_rows' => plot.variables.size - 1, 'row' => i,
            'row_margin' => row_margin)) do
          t.do_box_labels(plot.zone, plot.variables[0], plot.variables[i])
          t.show_plot(plot_boundaries(xs,ys,@margin)) { t.show_polyline(xs,ys,Red) }
        end
      end
    end
  end

end

class CompareTecplotter < Tecplotter

  def initialize(plots1, plots2)
    @t = FigureMaker.default
    @margin = 0.025
    @plots1 = plots1
    @plots2 = plots2

    if @plots1.length == @plots2.length
      @plots1.each_with_index do |plot1, plotnum|
        if plot1.variables.length == @plots2[plotnum].variables.length
          if true
            puts plotnum
            t.def_figure("#{plot1.title} - #{@plots2[plotnum].title}") {
              exec_plot_rows(plotnum) }
          else
            plot1.values.each_with_index do |vals, varnum|
              if varnum > 0
                t.def_figure("#{plot1.title} - #{@plots2[plotnum].title} - #{plot1.variables[varnum]}") {
                exec_plot2(plotnum, varnum) }
              end
            end
          end
        end
      end
    end

  end

  def exec_plot2(plotnum, varnum)
    #t.set_aspect_ratio(1)
    xs = @plots1[plotnum].values[0]
    t.do_box_labels(@plots1[plotnum].zone, @plots1[plotnum].variables[0], @plots1[plotnum].variables[varnum])
    boundaries = setup_lines(xs, [@plots1[plotnum].values[varnum], @plots2[plotnum].values[varnum]])
    t.show_plot(boundaries) do
      t.show_polyline(xs,@plots1[plotnum].values[varnum],Blue)
      t.show_polyline(xs,@plots2[plotnum].values[varnum],Red)
    end
  end

  def exec_plot_rows(plotnum)
    t.landscape
    t.rescale(0.8)
    t.do_box_labels(@plots1[plotnum].zone, @plots1[plotnum].variables[0], nil)
    xs = @plots1[plotnum].values[0]
    number_of_rows = @plots1[plotnum].values.length
    number_of_rows = number_of_rows - 1
    @plots1[plotnum].values.each_with_index do |vals, varnum|
      if varnum > 0
        t.subplot(t.row_margins('num_rows' => number_of_rows.to_f, 'row' => varnum.to_f)) do
          t.do_box_labels(@plots1[plotnum].zone, @plots1[plotnum].variables[0], @plots1[plotnum].variables[varnum])
          t.xaxis_type = AXIS_WITH_TICKS_ONLY if varnum != number_of_rows
          t.top_edge_type = AXIS_HIDDEN if varnum != 1
          boundaries = setup_lines(xs, [@plots1[plotnum].values[varnum], @plots2[plotnum].values[varnum]])
          t.show_plot(boundaries) do
            t.show_polyline(xs,@plots1[plotnum].values[varnum],Blue)
            t.show_polyline(xs,@plots2[plotnum].values[varnum],Red)
          end
        end
      end
    end
  end

end

loader = TecplotLoader.new

plots1 = loader.load_tec('min1.tec')
plots2 = loader.load_tec('min2.tec')

#plots1 = loader.load_tec('sample.tec')
#plots2 = loader.load_tec('sample2.tec')

CompareTecplotter.new(plots1, plots2)
