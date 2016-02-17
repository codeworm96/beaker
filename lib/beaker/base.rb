require 'rack'

module Beaker
  class Response < Rack::Response
    def initialize(*)
      super
      headers['Content-Type'] ||= 'text/html'
    end

    def finish
      [status.to_i, headers, body]
    end
  end

  class Base
    def call(env)
      @request = Rack::Request.new(env)
      @response = Response.new

      invoke { dispatch }

      @response.finish
    end

    # exit the current block
    def halt(*res)
      res = res.first if res.length == 1
      throw :halt, res
    end

    private

    # dispatch route
    def dispatch
      routes = self.class.routes[@request.request_method]
      if routes
        routes.each do |path, block|
          route_eval &block if path.match @request.path_info
        end
      end

      route_missing
    end

    # eval for a route block
    def route_eval(&block)
      throw :halt, instance_eval(&block)
    end

    # route_missing
    def route_missing
      throw :halt, [404, {'Content-Type' => 'text/html'}, ['Not found!']]
    end

    # invoke a block that throws :halt
    # and set the response
    def invoke
      res = catch(:halt) { yield }

      if String === res or Fixnum === res
        res = [res]
      end
      if Array === res and Fixnum === res.first
        @response.status = res.shift
        @response.body = res.pop if res.size > 0
        @response.headers.merge!(*res) if res.size > 0
      elsif res.respond_to? :each
        @response.body = res
      end
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
      subclass.reset!
    end

  end
end