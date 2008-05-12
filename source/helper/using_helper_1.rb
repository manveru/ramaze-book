class MainController < Ramaze::Controller
  helper :formatting

  def index
    number_format(rand)
  end
end
