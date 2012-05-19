require 'sinatra'
require 'omniauth'

use Rack::Session::Cookie
use OmniAuth::Builder do
    provider :twitter, 'loCcf78CNJieKohWf5KNCg', 'iPk4PAUEvQ1OPbsJhdei8U52NlhA5Z8N7Mc4DBgV79Q'
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

