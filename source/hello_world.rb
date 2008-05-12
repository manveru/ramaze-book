require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  def index
    "Hello, World"
  end
end

Ramaze.start
