require 'rubyzome/controllers/RestController.rb'
class FacebookController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Not available (should be done through admin) 
    def index
	action_not_available
    end

    def create
	check_authentication
	account = get_account
	user = get_user(:l)
	check_ownership_user_account(user,account)

	# Get access token
	begin
		facebook_key = clean_hash([:access_token])
		facebook = Twitter.new(facebook_key)
		facebook.save
		user.facebook = facebook
		user.save
	rescue Exception => e
		raise Rubyzome::Error, "Cannot create facebook object: #{e.message}"
	end
    end

    def show
	check_authentication
	account = get_account
	user = get_user(:l)
	check_ownership_user_account(user,account)
	
        clean_id(account.attributes.merge(account.user.attributes))
    end

    def update
	check_authentication
	account = get_account
	user = get_user(:l)
	check_ownership_user_account(user,account)

	begin
		# TODO
	rescue Exception => e
		raise Rubyzome::Error,"Cannot update facebook object: #{e.message}"
	end

	clean_id(account.attributes.merge(account.user.attributes))
    end

    def delete
	action_not_available
    end
end