require 'sinatra'
require 'sinatra/mongo'
require 'rack-flash'
require 'bcrypt'
require './lib/validate'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogera'
    enable :sessions
    use Rack::Flash, :sweep => true
end

get '/' do
    erb :signup
end

post '/signup' do
    if validate_email(params[:email]) and validate_password(params[:password])
        user_email = params[:email]
        user_pass = params[:password]
        pw_hash = BCrypt::Password.create(user_pass)
        mongo["users"].insert({"email"=>user_email,"password_hash"=>pw_hash})
        session[:user] = user_email
        flash[:success] = "You have successfully registered!"
        redirect('/home')
    else
        flash[:error] = "There were errors while submitting your form!"
        redirect('/')
    end
end

get '/login' do
    erb :login
end

post '/login' do
    user_email = params[:email]
    user_pass = params[:password]
    user = mongo["users"].find({"email" => user_email})
    if user.count == 0
        flash[:error] = "Invalid email/password combination"
        redirect('/login')
    end
    puts user.each do |doc|
        puts doc['email']
    end
    
    # session[:user] = user_email
    # flash[:success] = "You have successfully registered!"
    # redirect('/home')
end

get '/home' do 
    @user_email = session[:user]
    if not @user_email
        flash[:error] = "You need to signup first!"
        redirect('/')
    end
    erb :home
end
