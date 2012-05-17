require 'sinatra'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
end

get '/' do 
    "<a href='/login'>Login</a>"
end

get '/signup' do
    erb :login
end
