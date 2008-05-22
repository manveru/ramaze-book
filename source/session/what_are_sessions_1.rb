require 'ramaze'

class MainController < Ramaze::Controller
  HELLO = {
    'en' => "Hello, world!",
    'de' => "Hallo Welt!",
    'ja' => "ハロー。ワールド",
    'it' => "Ciao, mondo!",
  }

  def index
    language = HELLO.keys.sort_by{ rand }.first
    session[:language] = language
    redirect Rs(:greet)
  end

  def greet
    HELLO[session[:language]]
  end
end
