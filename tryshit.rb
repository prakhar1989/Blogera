require 'bcrypt'
pw_hash = BCrypt::Password.create("prakhar")

puts pw_hash == "wassap"
puts pw_hash == "prakhar"
