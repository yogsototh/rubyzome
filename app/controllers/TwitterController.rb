require 'rubyzome/controllers/RestController.rb'
class TwitterController < Rubyzome::RestController
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

	# Get consumer and access token
	begin
		twitter_keys = clean_hash([:consumer_token, :consumer_secret, :access_token, :access_secret])
		twitter = Twitter.new(twitter_keys)
		twitter.save
		user.twitter = twitter
		user.save
	rescue Exception => e
		raise Rubyzome::Error, "Cannot create twitter object: #{e.message}"
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
		raise Rubyzome::Error,"Cannot update twitter object: #{e.message}"
	end

	clean_id(account.attributes.merge(account.user.attributes))
    end

    def delete
	action_not_available
    end
end
