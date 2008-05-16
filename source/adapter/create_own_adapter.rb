require 'ramaze'

require 'mongrel'
require 'rack/handler/mongrel'

module Ramaze
  module Adapter
    class Mongrel < Base
      def self.startup(host, port)
        @server = ::Mongrel::HttpServer.new(host, port)
        @server.register('/', ::Rack::Handler::Mongrel.new(self))
        @thread = @server.run
        self
      end
    end
  end
end

class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end
end

Ramaze::start
