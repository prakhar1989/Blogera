require 'sinatra'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
end

get '/' do
	erb :signup
end

get '/login' do
    erb :login
end
