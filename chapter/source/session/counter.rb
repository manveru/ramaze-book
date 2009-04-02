require 'ramaze'

class Counter < Ramaze::Controller
  map '/'
  @@counter = 0

  def index
    "You are visitor number #{@@counter}"
  end

  private

  def count_visit
    return if session[:counted]
    @@counter += 1
    session[:counted] = true
  end

  before_all{ count_visit }
end

Ramaze.start
