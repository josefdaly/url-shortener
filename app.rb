require 'sinatra'
require 'json'
require 'securerandom'
require_relative './active-record-lite/sql_object'

Tilt.register Tilt::ERBTemplate, 'html.erb'

class Url < SQLObject
  self.finalize!
end

url = Url.where({shortened: '1'})

get '/' do
  send_file './index.html'
end

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
    short_url = SecureRandom::urlsafe_base64(3)
    unless Url.where( shortened: short_url ).size > 0
      condition = false
    end
  end
  if Url.where(url: long_url).size > 0
    existing_model = Url.where(url: long_url).first
    existing_model.attributes.to_json
  else
    new_model = Url.new({ url: long_url, shortened: short_url })
    new_model.save
    new_model.attributes.to_json
  end
end
