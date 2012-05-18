begin
    require 'sinatra'
    require 'omniauth'
    require 'openid/store/filesystem'
rescue LoadError
    require 'rubygems'
    require 'sinatra'
    require 'omniauth'
    require 'openid/store/filesystem'
end

use Rack::Session::Cookie
use OmniAuth::Builder do
    provider :open_id, OpenID::Store::Filesystem.new('/tmp')
    provider :twitter, 'consumerkey', 'consumersecret'
end

get '/' do
    <<-HTML
<a href='/auth/twitter'>Sign in with Twitter</a>

<form action='/auth/open_id' method='post'>
  <input type='text' name='identifier'/>
  <input type='submit' value='Sign in with OpenID'/>
</form>
    HTML
end

post '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    # do whatever you want with the information!
end

