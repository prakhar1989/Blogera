require 'sinatra'
require 'sinatra/mongo'
require 'rack-flash'
require 'bcrypt'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogera'
    enable :sessions
    use Rack::Flash, :sweep => true
end

#TODO: I would ideally want to move these validation functions
#in a separate file to keep this part clean. Please do it 
#if you know how to get that done!
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
    puts user
    # if user.nil?
    #     flash[:error] = "Invalid email/password combination"
    #     redirect('/login')
    # end
end

get '/home' do 
    @user_email = session[:user]
    if not @user_email
        flash[:error] = "You need to signup first!"
        redirect('/')
    end
    erb :home
end
