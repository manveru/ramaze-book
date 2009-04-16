require 'rubygems'
require 'ramaze'

class Hello < Ramaze::Controller
  def index
    "Hello, World"
  end
end

Ramaze.start
