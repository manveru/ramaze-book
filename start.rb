require 'ramaze'
require 'rake'

class MainController < Ramaze::Controller
  def index
    sh 'rake', 'build'
    respond File.read('ramaze.html')
  end
end

Ramaze.start :adapter => :mongrel
