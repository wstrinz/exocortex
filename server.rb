Encoding.default_internal = Encoding.default_external = 'UTF-8'

def path_to(dir)
  File.join(File.dirname(__FILE__), dir)
end

require 'bundler/setup'
require 'sinatra'
require 'sinatra/linkeddata'
require 'sinatra/cross_origin'

require path_to('lib/archivist')

helpers do
  def error_response(code)
    status code
  end

  def find_resource

  end
end

configure :development do
  require 'sinatra/reloader'
  require 'pry'
  Sinatra::Application.also_reload "lib/**/*.rb"
end

configure do
  set :repository, RDF::Repository.new
  enable :cross_origin
end

get '/' do
  "landing page goes here"
end

get '*' do
  repo = settings.repository

  unless repo
    error_response 404
  end

  result = find_resource

  if result
    result
  else
    error_response 404
  end
end

post '*' do
  repo = settings.repository

  unless repo
    error_response 404
  end

  result = create_resource

  if result
    result
  else
    error_response 422
  end
end

put '*' do
  repo = settings.repository

  unless repo
    error_response 404
  end

  result = update_resource

  if result
    result
  else
    error_response 404
  end
end

delete '*' do
  repo = settings.repository

  unless repo
    error_response 404
  end

  result = delete_resource

  if result
    result
  else
    error_response 404
  end
end
