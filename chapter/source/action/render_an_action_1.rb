class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end
end

Ramaze::Action(:controller => MainController, :method => :index).render
# => "Hello, World!"
