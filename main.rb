require 'sinatra'
require 'sinatra/mongo'
require 'rack-flash'
require './lib/validate'
require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-facebook'

configure do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :mongo, 'mongo://localhost:27017/blogera'
    enable :sessions
    use Rack::Flash, :sweep => true
    use OmniAuth::Strategies::Twitter, 'loCcf78CNJieKohWf5KNCg', 'iPk4PAUEvQ1OPbsJhdei8U52NlhA5Z8N7Mc4DBgV79Q'
    use OmniAuth::Builder do
        provider :facebook, '351336024898423', '426e74cac68fe2a9182ffe7db3744399'
    end
end

get '/' do
    session[:authorized] = false
    erb :signup
end

post '/signup' do
    if validate_email(params[:email]) and validate_password(params[:password])
        provider = "standard"
        register_user(params[:email],params[:password], provider)
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

get '/auth/:name/callback' do
    content_type 'application/json'
    auth = request.env['omniauth.auth']
    uid = auth["uid"] #TODO: Is it fine to use UID as password?
    nickname = auth["info"]["nickname"]
    provider =  auth["provider"]
    register_user(nickname, uid, provider)
    authorize_user(nickname, session)
    redirect('/home')
end

get '/auth/failure' do
    flash[:error] = "We encountered an error while fetching your data from twitter. Please try again!"
    redirect('/')
end
