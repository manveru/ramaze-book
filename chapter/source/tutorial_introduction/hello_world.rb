require 'ramaze'

class HelloController < Ramaze::Controller

  map "/"

  def index
    "Hello, World"
  end

end

Ramaze.start
