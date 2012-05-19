require 'sinatra/base'
require 'bcrypt'

module Sinatra
    module ExtraHelpers
        def cleanup_users()
            mongo["users"].remove()
        end

        def cleanup_posts()
            mongo["posts"].remove()
        end

        def add_dummy_posts(uid = 1, n = 5)
            n.times do 
                title = (0...4).map{ ('a'..'z').to_a[rand(26)] }.join
                content = (0...20).map{ ('a'..'z').to_a[rand(26)] }.join
                mongo["posts"].insert({:uid => uid, 
                                      :title => title, 
                                      :content => content, 
                                      :created_at => Time.new,
                                      :last_modified => Time.new })
            end
        end
    end
    register ExtraHelpers
end

