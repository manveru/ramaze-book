require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  map '/'

  def index
    "Hello, World!"
  end

  def sum(*numbers)
    numbers.inject(0.0){|sum, num| sum + num.to_f }.to_s
  end
end

index = MainController.resolve('index')
index.call # =>
