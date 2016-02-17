require_relative 'lib/beaker'

class App < Beaker::Base
  get '/' do
    'Hello, world!'
  end

  get '/admin' do
    403
  end

  get /reg\/\w+/ do
    'Regexp.'
  end

end

App.run!