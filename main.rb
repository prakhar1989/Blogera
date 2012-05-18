require 'sinatra'
require 'sinatra/mongo'
require 'rack-flash'
require './lib/validate'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogera'
    enable :sessions
    use Rack::Flash, :sweep => true
end

get '/' do
    session[:authorized] = false
    erb :signup
end

post '/signup' do
    if validate_email(params[:email]) and validate_password(params[:password])
        register_user(params[:email],params[:password])
        authorize_user(params[:email],session)
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
    if registered_user?(params[:email],params[:password])
        authorize_user(params[:email],session)
        flash[:success] = "You have successfully logged in!"
        redirect('/home')
    else
        flash[:error] = "Invalid email/password combination"
        redirect('/login')
    end
end

get '/logout' do
    session.clear
    flash[:success] = "You have successfully logged out!"
    redirect('/')
end

get '/home' do 
    if !logged_in?(session)
        flash[:error] = "You need to signup first!"
        redirect('/')
    end
    erb :home, :locals => { :session => session }
end
