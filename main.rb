require 'sinatra'
require 'sinatra/mongo'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogera'
end

get '/' do
    erb :signup
end

post '/signup' do
	mongo["users"].insert({"email"=>params[:email],"password"=>params[:password]})
end

get '/login' do
    erb :login
end

