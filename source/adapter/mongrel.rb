module Ramaze
  module Adapter
    class Mongrel < Base
      def self.startup(host, port)
        @server = ::Mongrel::HttpServer.new(host, port)
        @server.register('/', ::Rack::Handler::Mongrel.new(self))
        @server.run
      end
    end
  end
end
