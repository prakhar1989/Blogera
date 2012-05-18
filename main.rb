require 'sinatra'
require 'sinatra/mongo'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogera'
end

puts mongo["testCollection"].insert({"name" => "mongo", "type" => "database", "count" => 1, "info" => { "x" => 203, "y" => "102" }})

get '/' do
    erb :signup
end

post '/signup' do
    if validate_email(params[:email]) and validate_password(params[:password])
        pw = params[:password]
        pw_hash = get_hashed_password(params[:password])
        salt = 4 #some randomly generated number
        user_token = get_generated_token(params[:email], salt)
        mongo["users"].insert({"email"=>params[:email],"password_hash"=>pw_hash, "token" => user_token})
    else
        #set_flash = "there was an error while registering"
        redirect('/')
    end
end

get '/login' do
    erb :login
end

get '/mongo' do
    my_array = mongo["testCollection"].find_one
    my_array.map{ |i| i.to_s }.join(",")
end
