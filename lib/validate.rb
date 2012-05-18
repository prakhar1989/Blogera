require 'sinatra/base'

module Sinatra
	module Validate
		def validate_email(email)
		    email_regex = /^[\S]+@[\S]+\.[\S]+$/
		    email_regex =~ email
		end
		def validate_password(password)
		    pass_regex = /^.{3,20}$/
		    pass_regex =~ password
		end
	end

	register Validate
end