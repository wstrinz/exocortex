Encoding.default_internal = Encoding.default_external = 'UTF-8'

def path_to(dir)
  File.join(File.dirname(__FILE__), dir)
end

require 'bundler/setup'
require 'sinatra'
require 'sinatra/linkeddata'
require 'sinatra/cross_origin'
require 'redis'
require 'active_support'

require path_to('lib/archivist')

helpers do
  def error_response(code)
    status code
  end

  def find_resource
  end

  def redis
    @redis ||= Redis.new
  end

  def remember_thing
    data = request.body.read
    JSON.parse(data)
    redis.rpush('to_remember', data)
  end

  def get_top_of_queue
    JSON.parse redis.lpop('to_remember')
  end

  def update_resource
    data = params[:data]

    properties = data.except('url').keys.each_with_object({}) do |key, hash|
      hash[data[key]['predicate']] = data[key]['object']
    end

    redis.set(data['url']['object'], properties.to_json) == "OK"
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
  haml :error
end

get '/queue' do
  @first_object = get_top_of_queue

  haml :queue
end

post '/queue' do
  successful = update_resource

  if successful
    "It worked"
  else
    status 500
    "It didn't"
  end
end

post '/remember' do
  successful = remember_thing

  content_type :json

  if successful
    {success: 'true'}.to_json
  else
    status 500
    {error: 'something went wrong'}.to_json
  end
end

# get '*' do
#   repo = settings.repository

#   unless repo
#     error_response 404
#   end

#   result = find_resource

#   if result
#     result
#   else
#     error_response 404
#   end
# end

# post '*' do
#   repo = settings.repository

#   unless repo
#     error_response 404
#   end

#   result = create_resource

#   if result
#     result
#   else
#     error_response 422
#   end
# end

# put '*' do
#   repo = settings.repository

#   unless repo
#     error_response 404
#   end

#   result = update_resource

#   if result
#     result
#   else
#     error_response 404
#   end
# end

# delete '*' do
#   repo = settings.repository

#   unless repo
#     error_response 404
#   end

#   result = delete_resource

#   if result
#     result
#   else
#     error_response 404
#   end
# end



