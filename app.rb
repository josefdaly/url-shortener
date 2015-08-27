require 'sinatra'
require_relative './active-record/db_connection'
require_relative './active-record/sql_object'

class Url < SQLObject
  self.finalize!
end

get '/urls' do
  @urls = Url.all
end

get '/:path' do 
  if Url.where(params[:path]).size > 0
    redirect
