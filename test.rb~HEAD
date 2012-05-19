require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-facebook'
require 'sinatra'

use Rack::Session::Cookie
use OmniAuth::Builder do
    provider :twitter, 'loCcf78CNJieKohWf5KNCg', 'iPk4PAUEvQ1OPbsJhdei8U52NlhA5Z8N7Mc4DBgV79Q'
    provider :facebook, '351336024898423', '426e74cac68fe2a9182ffe7db3744399'
end

get '/' do
    <<-HTML
<a href='/auth/twitter'>Sign in with Twitter</a>
<a href='/auth/facebook'>Sign in with facebook</a>
    HTML
end

post '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    # do whatever you want with the information!
end

get '/auth/:name/callback' do
    content_type 'application/json'
    auth = request.env['omniauth.auth']
    MultiJson.dump(auth, :pretty=>true)
end

get '/auth/failure' do
    "Oops! GG!"
end
