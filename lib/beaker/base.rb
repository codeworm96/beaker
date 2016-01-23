require 'rack'

module Beaker
  class Base
    def call(env)
      @request = Rack::Request.new(env)
      if @request.path_info == '/'
        ['200', {'Content-Type' => 'text/html'}, ['Hello world!']]
      else
        ['404', {'Content-Type' => 'text/html'}, ['Not found!']]
      end
    end

    class << self
      def call(env)
        new.call(env)
      end

      def run!
        handler = Rack::Handler.get('thin')
        handler.run(self, {Port: 4000, Host: '127.0.0.1'})
      end
    end
  end
end