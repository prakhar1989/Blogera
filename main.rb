require 'sinatra'
require 'sinatra/mongo'
require 'rack-flash'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogera'
    enable :sessions
    use Rack::Flash
end

def validate_email(email)
    email_regex = /^[\S]+@[\S]+\.[\S]+$/
    return true if email_regex =~ email
end
def validate_password(password)
    pass_regex = /^.{3,20}$/
    return true if pass_regex =~ password
end

puts mongo["testCollection"].insert({"name" => "mongo", "type" => "database", "count" => 1, "info" => { "x" => 203, "y" => "102" }})

get '/' do
    erb :signup
end

post '/signup' do
    if validate_email(params[:email]) and validate_password(params[:password])
        flash[:success] = "You have successfully registered!"
        redirect('/home')
        # pw = params[:password]
        # pw_hash = get_hashed_password(params[:password])
        # salt = 4 #some randomly generated number
        # user_token = get_generated_token(params[:email], salt)
        # mongo["users"].insert({"email"=>params[:email],"password_hash"=>pw_hash, "token" => user_token})
    else
        flash[:error] = "There were errors while submitting your form!"
        redirect('/')
    end
end

get '/login' do
    erb :login
end

get '/home' do 
    erb :home
end
