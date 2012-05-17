require 'sinatra'
require 'sinatra/mongo'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogtest'
end

puts mongo["testCollection"].insert({"name" => "mongo", "type" => "database", "count" => 1, "info" => { "x" => 203, "y" => "102" }})

get '/' do
    erb :signup
end

get '/login' do
    erb :login
end

get '/mongo' do
    my_array = mongo["testCollection"].find_one
    my_array.map{ |i| i.to_s }.join(",")
end
