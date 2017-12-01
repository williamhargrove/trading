#!/usr/bin/ruby -w

class Index
  require 'csv'

  def initialize(index)
    # Instance variables
    @index = index
    @prices = initial_load
  end 
 
  def initial_load
    CSV.readlines(@index, headers: true)
  end

  def sma(period=21)
    ma = Array.new 
    # reverse array so that newest prices are at the top
    @prices.reverse_each {|p| ma.push p}
    sma=0.0
    period.times do |p|
      sma += ma[p][5].to_f
    end
    sma /= period
  end

end

ftse250 = Index.new('^xFTMC.csv')

puts ftse250.sma(21)

# The following line is for Vim users - please don't delete it.
# vim: set filetype=ruby expandtab tabstop=2 shiftwidth=2:
