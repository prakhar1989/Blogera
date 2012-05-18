require 'sinatra/base'
require 'bcrypt'

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
		def registered_user?(user,pass)
			user_cursor = mongo["users"].find({"email" => user})
			user_array = user_cursor.to_a[0]
			BCrypt::Password.new(user_array["password_hash"]) == pass if user_cursor.count > 0
		end
		def authorize_user(user,session)
			session[:user] = user
			session[:authorize] = true
		end
		def logged_in?(session)
			session[:authorize]
		end
		def register_user(email,password)
			pw_hash = BCrypt::Password.create(password)
			mongo["users"].insert({"email"=>email,"password_hash"=>pw_hash})
		end
	end

	register Validate
end