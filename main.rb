require 'sinatra'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
end

get '/signup' do
    erb :login
end
