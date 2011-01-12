module Helpers

    ### AUTHENTICATION ###

    def check_authentication
        if @request[:l] != 'adm' then
            raise Rubyzome::Error, "Only admin is authorized to perform this action"
        end

        if @request[:p] != 'adm' then
            raise Rubyzome::Error, "Authentication failed, please check your login and password"
        end
    end

    ### ACCOUNT STUFF ###

    def get_account(id=:account_id)
        account_id = @request[id]
        if(account_id.nil?) then
            raise Rubyzome::Error, "No user provided"
        end
        user = User.first({:nickname => account_id})
        if(user.nil?) then
            raise Rubyzome::Error, "User #{account_id} does not exist"
        end
        account = user.account
        if(account.nil?) then
            raise Rubyzome::Error, "No account linked to user #{user_id}"
        end
        return account
    end

    ### USER STUFF ###

    def get_user(id=:user_id)
        user_id = @request[id]
        if(user_id.nil?) then
            raise Rubyzome::Error, "No user provided"
        end
        user = User.first({:nickname => user_id})
        if(user.nil?) then
            raise Rubyzome::Error, "User #{user_id} does not exist"
        end
        return user
    end

    ### SENSOR STUFF ###

    def get_sensor(id=:sensor_id)
        sensor_id = @request[id]
        if(sensor_id.nil?) then
            raise Rubyzome::Error, "No sensor provided"
        end
        sensor = Sensor.first({:sensor_hr => sensor_id})
        if(sensor.nil?) then
            raise Rubyzome::Error,"Sensor #{sensor_id} does not exist"
        end
        return sensor
    end

    ### MEASURE STUFF ###

    def get_measure(id=:measure_id)
        measure_id = @request[id]
        if(measure_id.nil?) then
            raise Rubyzome::Error, "No measure provided"
        end
        measure = Measure.first({:measure_hr => measure_id})
        if(measure.nil?) then
            raise Rubyzome::Error,"Measure #{measure_id} does not exist"
        end
        return measure
    end

    ### OWNERSHIP ###

    def check_ownership_user_account(user,account)
        if account.user_id = user
            raise Rubyzome::Error, "Account is not linked to user #{user.nickname}"
        end
    end

    def check_ownership_user_sensor(user,sensor)
        if sensor.user != user then
            raise Rubyzome::Error, "Sensor #{sensor.sensor_hr} does not belong to User #{user.nickname}"
        end
    end

    def check_ownership_sensor_measure(sensor,measure)
        if measure.sensor != sensor then
            raise Rubyzome::Error, "Measure #{measure.measure_hr} does not belong to Sensor #{sensor.sensor_hr}"
        end
    end

    ### ONLY USED IN USER PART ###

    def check_ownership_requestor_user(requestor,user)
        if requestor.nickname != user.nickname
            raise Rubyzome::Error, "Requestor #{requestor.nickname} and user requested #{user.nickname} do not match"
        end
    end


    ### UTIL ###

    def clean_id(hash)
        hash.delete(:id)
        hash.delete(:user_id)
        hash.delete(:account_id)
        hash.delete(:sensor_id)
        hash
    end

    ### STAT PURPOSES ###

    def get_start_date
        days_nbr = 1
        days_nbr = @request[:days_nbr] if not @request[:days_nbr].nil?
        start_date = DateTime.now - days_nbr.to_i
        return start_date
    end

    ### TWITTER ###

    def update_twitter(nickname, status)
	require 'twitter'
	puts "About to update Twitter account for user #{nickname} with #{status}"

        # Get user from nickname
	user = User.first({:nickname => nickname})

	# Get Twitter account if exists
	account = TwitterAccount.first({:user => user})
	if account.nil? then
		puts "No twitter account found for user #{nickname}"
		return
	end

	# Build message
	message = %{Nouveau status: #{status}}

	# Get keys
	consumer_token=account.consumer_token
	consumer_secret=account.consumer_secret
	access_token=account.access_token
	access_secret=account.access_secret

	# OAuth connect
	oauth = Twitter::OAuth.new(consumer_token, consumer_secret)
	oauth.authorize_from_access(access_token, access_secret)
	client = Twitter::Base.new(oauth)

	# Update timeline
	client.update(message)
    end


    ### FACEBOOK ###

    def update_facebook(nickname, status)
	require 'koala'
	puts "About to update Facebook account for user #{nickname} with #{status}"

        # Get user from nickname
	user = User.first({:nickname => nickname})

        # Get Facebook account if exists
	account = FacebookAccount.first({:user => user})
	if account.nil? then
		puts "No facebook account found for user #{nickname}"
		return
	end

	# Build message
	message = %{Nouveau status: #{status}}

	# Get key
	access_token=account.access_token

	# Connect
	graph = Koala::Facebook::GraphAPI.new(access_token)

	# Update wall
	graph.put_object("me", "feed", :message => message)
    end
    
end
