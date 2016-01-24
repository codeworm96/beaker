require 'rack'

module Beaker
  class Base
    def call(env)
      @request = Rack::Request.new(env)

      # Can not handle error correctly now!

      self.class.routes[@request.request_method].each do |path, block|
        return block.call if path.match @request.path_info
      end

      ['404', {'Content-Type' => 'text/html'}, ['Not found!']]
    end

    class << self
      attr_reader :routes

      def reset!
        @routes = {}
      end

      def call(env)
        new.call(env)
      end

      def run!
        handler = Rack::Handler.get('thin')
        handler.run(self, {Port: 4000, Host: '127.0.0.1'})
      end

      def route(verb, path, &block)
        # init list
        @routes[verb] ||= []

        @routes[verb] << [path, block]
      end

      def get(path, &block)
        route 'GET', path, &block
        # Defining 'GET' also automatically defines 'HEAD'
        route 'HEAD', path, &block
      end

      def put(path, &block)
        route 'PUT', path, &block
      end

      def post(path, &block)
        route 'POST', path, &block
      end

      def delete(path, &block)
        route 'DELETE', path, &block
      end

      def head(path, &block)
        route 'HEAD', path, &block
      end

      def options(path, &block)
        route 'OPTIONS', path, &block
      end

      def patch(path, &block)
        route 'PATCH', path, &block
      end

      def link(path, &block)
        route 'LINK', path, &block
      end

      def unlink(path, &block)
        route 'UNLINK', path, &block
      end

    end

    # init routes
    reset!

    # hook to get subclass initialized
    def self.inherited(subclass)
      super
      subclass.reset!
    end

  end
end