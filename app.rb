require 'sinatra'
require 'json'
require_relative './active-record/db_connection'
require_relative './active-record/sql_object'

Tilt.register Tilt::ERBTemplate, 'html.erb'

class Url < SQLObject
  self.finalize!
end

Url.new({ url: 'https://www.google.com', shortened: '1' }).save
Url.new({ url: 'https://www.example.com', shortened: '2' }).save

get '/urls' do
  content_type :json
  urls_array = []
  urls = Url.all
  urls.each do |url_model|
    urls_array.push(url_model.attributes)
  end

  
end

#
# get '/:path' do
#   url =
#   if Url.where(params[:path]).size > 0
#     redirect
