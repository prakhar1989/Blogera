require 'sinatra'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
end

get '/login' do
	redirect '/signup'
end

get '/signup' do
    erb :login
end
