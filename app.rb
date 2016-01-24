require_relative 'lib/beaker'

class Beaker::Base
  get '/' do
    ['200', {'Content-Type' => 'text/html'}, ['Hello, world!']]
  end

  get /\w+/ do
    ['200', {'Content-Type' => 'text/html'}, ['Regexp.']]
  end

end

Beaker::Base.run!