require 'sinatra'
require 'json'
require 'securerandom'
require_relative './active-record/db_connection'
require_relative './active-record/sql_object'

Tilt.register Tilt::ERBTemplate, 'html.erb'

class Url < SQLObject
  self.finalize!
end

Url.new({ url: 'https://www.google.com', shortened: '1' }).save
Url.new({ url: 'https://www.example.com', shortened: '2' }).save
Url.new({ url: 'https://www.wikipedia.org', shortened: '3' }).save

get '/url_index' do
  content_type :json
  urls_array = []
  urls = Url.all
  urls.each do |url_model|
    urls_array.push(url_model.attributes)
  end

  urls_array.to_json
end

get '/:path' do
  url_array = Url.where(shortened: params[:path])
  if url_array.size > 0
    redirect url_array.first.url
  else
    erb :invalid
  end
end

post '/new' do
  content_type :json
  condition = true
  long_url = params[:url]
  while condition
    short_url = SecureRandom::base64(6)
    condition = false unless Url.where( shortened: short_url ).size > 0
  end
  if Url.where(url: long_url).size > 0
    {}.to_json
  else
    new_model = Url.new({ url: long_url, shortened: short_url })
    new_model.save
    new_model.attributes.to_json
  end
end
