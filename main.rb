require 'sinatra'
require 'sinatra/mongo'
require 'rack-flash'
require './lib/validate'
require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-facebook'
require './lib/extra_helpers'
require 'rdiscount'

configure do
    set :mongo, 'mongo://localhost:27017/blogera'
    enable :sessions
    use Rack::Flash, :sweep => true
    use OmniAuth::Builder do
        provider :facebook, '351336024898423', '426e74cac68fe2a9182ffe7db3744399'
        provider :twitter, 'loCcf78CNJieKohWf5KNCg', 'iPk4PAUEvQ1OPbsJhdei8U52NlhA5Z8N7Mc4DBgV79Q'
    end
    get '/stylesheets/:stylesheet.css' do |stylesheet|
        scss :"scss/#{stylesheet}"
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
        #TODO: Add uniqueness constraint on email!
    end
end

get '/login' do
    if !logged_in?(session)
        erb :login
    else
        flash[:success] = "You have already logged in!"
        redirect('/home')
    end
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

get '/auth/:name/callback' do
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

get '/home' do 
    #TODO: Isn't it wise to make the following check(with the flash) 
    #as a helper which can be called be on each view
    if !logged_in?(session)
        flash[:error] = "You need to signup first!"
        redirect('/')
    end
    @posts_cursor = mongo["posts"].find({:uid => session[:uid]})
    erb :home
end

get '/new' do
    #TODO: Isn't it better to make this a helper?(along with flash setting)
    if !logged_in?(session)
        flash[:error] = "You need to signup first!"
        redirect('/')
    end
    erb :new
end

post '/new' do
    title = params[:title]
    content = params[:content]
    if title.empty? or content.empty?
        flash[:error] = "Cant Post Empty Fields!" #TODO: make a flash helper
        redirect('/new')
    end
    content_mkd = RDiscount.new(content).to_html
    mongo["posts"].insert({"uid" =>  session[:uid],
                           "title" => title,
                           "content" => content_mkd,
                           "created_at" => Time.new,
                           "last_modified" => Time.new})
    redirect('/home')
end

