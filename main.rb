require 'sinatra'
require 'sinatra/mongo'
require 'rack-flash'
require './lib/validate'
require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-facebook'
require './lib/extra_helpers'
require 'rdiscount'
require 'eventmachine'
require 'SmtpRubyServer'

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
    set(:auth) do |*roles| # <- notice the splat here
      condition do
        unless logged_in?(session)
            flash[:error] = "You need to login first!"
            redirect('/')
        end
      end
    end
    EventMachine::run {
        EM.start_server '0.0.0.0', 25, SmtpRubyServer
    }
end

helpers do 
    def get_post_permalink(post)
        #eg: http://blogera.io/prakhar/post/532131323/hello-world
        post_id = post["_id"]
        slug = post["title"].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        "#{session[:nickname]}/post/#{post_id}/#{slug}"
    end
end


get '/' do
    session[:authorized] = false unless session[:authorized]
    erb :signup
end

post '/signup' do
    if validate_email(params[:email]) and validate_password(params[:password])
        provider = "standard"
        register_user(params[:email],params[:nickname],params[:password], provider)
        authorize_user(params[:nickname],session)
        flash[:success] = "You have successfully registered!"
        redirect('/'+session[:nickname])
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
        redirect('/'+session[:nickname])
    end
end

post '/login' do
    if registered_user?(params[:email],params[:password])
        authorize_user(params[:email],session)
        flash[:success] = "You have successfully logged in!"
        redirect('/'+session[:nickname])
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
    register_user("",nickname, uid, provider)
    authorize_user(nickname, session)
    redirect('/'+session[:nickname])
end

get '/auth/failure' do
    flash[:error] = "We encountered an error while fetching your data from twitter. Please try again!"
    redirect('/')
end

get '/:name', :auth => ["user"] do
    #TODO: Isn't it wise to make the following check(with the flash) 
    #as a helper which can be called be on each view
    @posts_cursor = mongo["posts"].find({:uid => session[:uid]})
    erb :home, :locals => { :session => session }
end

get '/:name/new' do
    #TODO: Isn't it better to make this a helper?(along with flash setting)
    if !logged_in?(session)
        flash[:error] = "You need to signup first!"
        redirect('/')
    end
    erb :new, :locals => { :session => session }
end

post '/:name/new' do
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
    redirect('/'+session[:nickname])
end

get '/:name/post/:id/*' do
    @post = mongo["posts"].find_one({:_id => BSON::ObjectId(params[:id].to_str)})
    @name = params[:name]
    erb :showpost
end
