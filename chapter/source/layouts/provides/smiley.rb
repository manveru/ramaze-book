require 'ramaze'

class Smiley < Ramaze::Controller
  map '/'
  layout :default
  provide :frown, :engine => :Etanni
  provide :smile, :engine => :Etanni

  def index
    'emotions ftw!'
  end
end

Ramaze.start(:root => './')
