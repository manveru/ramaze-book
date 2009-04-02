require 'ramaze'

class CookieCounter < Ramaze::Controller
  map '/'

  def index
    "This is your visit number #{@count}"
  end

  private

  def count_visit
    counter = request.cookies['counter'].to_i
    @count = counter + 1
    response.set_cookie('counter', @count)
  end

  before_all{ count_visit }
end

Ramaze.start
