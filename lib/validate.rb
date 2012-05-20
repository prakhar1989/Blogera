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
            #Should this go here?
            user_detail = mongo["users"].find({:email => user})
            if (user_detail.count == 0)
            	user_detail = mongo["users"].find({:nickname => user})
            end
            user_array = user_detail.to_a[0]
            session[:uid] = user_array["_id"]
			session[:authorized] = true
			session[:nickname] = user_array["nickname"]
		end
		def logged_in?(session)
			session[:authorized]
		end
		def register_user(email,nickname,password,provider)
            pw_hash = BCrypt::Password.create(password) 
			mongo["users"].insert({"email"=>email,"nickname"=>nickname,"password_hash"=>pw_hash, "provider"=>provider}) if !user_exist?(nickname)
		end
		def user_exist?(nickname)
			mongo["users"].find({:nickname=>nickname}).count > 0
		end
	end

	register Validate

end
