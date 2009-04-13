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

index = Ramaze::Action.create(
          :node => MainController,
          :method => :index,
          :engine => lambda{|action, value| value })
index.call # =>
