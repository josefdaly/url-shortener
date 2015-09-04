require 'sinatra'
require 'json'
require 'securerandom'
require_relative './active-record-lite/sql_object'

Tilt.register Tilt::ERBTemplate, 'html.erb'

class Url < SQLObject
  has_many('clicks', {
    class_name: 'Click',
    primary_key: 'id',
    foreign_key: 'url_id'
  })
  self.finalize!
end

class Click < SQLObject
  belongs_to('url', {
    class_name: 'Url',
    primary_key: 'id',
    foreign_key: 'url_id'
  })
  belongs_to('clicker', {
    class_name: 'Clicker',
    primary_key: 'id',
    foreign_key: 'clicker_id'
  })
  self.finalize!
end

class Clicker < SQLObject
  has_many('clicks',{
    class_name: 'Click',
    primary_key: 'id',
    foreign_key: 'clicker_id'
  })
  self.finalize!
end

get '/' do
  send_file './public/html/index.html'
end

get '/most_recent/:amount' do
  content_type :json
  amount = params[:amount].to_i
  urls_array = []
  urls = Url.last(amount)
  urls.each do |url_model|
    urls_array.push(url_model.attributes)
  end

  urls_array.to_json
end

get '/oldest/:amount' do
  content_type :json
  amount = params[:amount].to_i
  urls_array = []
  urls = Url.first(amount)
  urls.each do |url_model|
    urls_array.push(url_model.attributes)
  end

  urls_array.to_json
end

get '/docs' do
  send_file './docs.html'
end

get '/url_index' do
  content_type :json
  urls_array = []
  urls = Url.all
  # byebug
  urls.each do |url_model|
    num_clicks = 0;
    if url_model.clicks.count
      num_clicks = url_model.clicks.count
    end
    urls_array.push(url_model.attributes.merge({
      'num_clicks' => num_clicks
    }))
  end

  urls_array.to_json
end

get '/click_index' do
  content_type :json
  clicks_array = []
  clicks = Click.all
  clicks.each do |click_model|
    clicks_array.push(click_model.attributes.merge({
      'url' => click_model.url.attributes,
      'clicker' => click_model.clicker.attributes
    }))
  end

  clicks_array.to_json
end

get '/clicker_index' do
  content_type :json
  clickers_array = []
  clickers = Clicker.all
  clickers.each do |clicker_model|
    clickers_array.push(clicker_model.attributes.merge({
      'num_clicks' => clicker_model.clicks.count
    }))
  end

  clickers_array.to_json
end

get '/:path' do
  @ip = request.ip

  url_array = Url.where(shortened: params[:path])

  if url_array.size > 0
    url_model = url_array.first

    clicker = Clicker.where(ip_address: @ip).first

    unless clicker
      clicker = Clicker.new(ip_address: @ip)
      clicker.save
    end
    Click.new({ url_id: url_model.id, clicker_id: clicker.id }).save

    redirect url_model.url
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
