require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end

  def sum(*numbers)
    numbers.inject(0.0){|sum, num| sum + num.to_f }.to_s
  end
end

sum = Ramaze::Action.create(
          :node => MainController,
          :method => :sum,
          :params => ['32', '8', '2'],
          :engine => lambda{|action, value| value })
sum # => 
sum.call # =>
sum # =>
