require 'rubyzome/controllers/RestController.rb'
class TwitteraccountController < Rubyzome::RestController
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
		# Delete current twitter account if any
		currentTwitterAccount = user.twitterAccount
		if(!currentTwitterAccount.nil?) then
			currentTwitterAccount.destroy
		end

		twitter_keys = clean_hash([:consumer_token, :consumer_secret, :access_token, :access_secret])
		twitterAccount = TwitterAccount.new(twitter_keys)
		twitterAccount.save
		user.twitterAccount = twitterAccount
		user.save
		clean_id(twitterAccount.attributes.merge(user.attributes))
	rescue Exception => e
		raise Rubyzome::Error, "Cannot create twitterAccount object: #{e.message}"
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
	# Not used
    end

    end

    def delete
	check_authentication
	account = get_account
	user = get_user(:l)
	check_ownership_user_account(user,account)

	# Get consumer and access token
	begin
		# Delete current twitter account if any
		currentTwitterAccount = user.twitterAccount
		if(!currentTwitterAccount.nil?) then
			currentTwitterAccount.destroy
		end
	rescue Exception => e
		raise Rubyzome::Error, "Cannot create twitterAccount object: #{e.message}"
	end
    end
    end
end
