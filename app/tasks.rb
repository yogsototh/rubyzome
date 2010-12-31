namespace "test" do
    server="http://localhost:8080"
    user="johndoe"
    pass="guest"

    task :all do
        Rake.application.invoke_task("test:measures")
        Rake.application.invoke_task("test:mobiles")
    end

    def uri_test(descr, uri)
        print %{#{descr}: }
        content=URI.parse(uri).read
        if /exception/.match(content)
            puts "Failed:"
            puts uri
            puts content
        else
            puts "Passed"
        end
    end

    task :measures do
        require 'open-uri'
        main_uri=server
        main_uri<<="/users/#{user}"
        main_uri<<="/sensors/#{user}_1"
        main_uri<<="/measures.json"
        main_uri<<="?l=#{user}&p=#{pass}"
        target_uri=main_uri
        uri_test( 'Last measure', target_uri )

        target_uri=%{#{main_uri}&from=#{(DateTime.now - 1).strftime}}
        uri_test( 'From', target_uri )

        target_uri=%{#{target_uri}&to=#{(DateTime.now).strftime}}
        uri_test( 'From To', target_uri )

        target_uri=%{#{target_uri}&interval=1800}
        uri_test( 'From To Interval', target_uri )
    end

    task :mobiles do
        require 'open-uri'
        main_uri=server
        main_uri<<="/users/#{user}"
        main_uri<<="/sensors/#{user}_1"
        main_uri<<="/mobiles.json"
        main_uri<<="?l=#{user}&p=#{pass}"
        target_uri=main_uri
        uri_test( 'Last measure', target_uri )

        target_uri=%{#{main_uri}&from=#{(DateTime.now - 1).strftime}}
        uri_test( 'From', target_uri )

        target_uri=%{#{target_uri}&to=#{(DateTime.now).strftime}}
        uri_test( 'From To', target_uri )

        target_uri=%{#{target_uri}&interval=1800}
        uri_test( 'From To Interval', target_uri )
    end
end

namespace "db" do

    task :compress do
        require 'rubygems'
        require 'dm-core'
        # configuration of DB
        require 'global'

        interval=300
        decal=5*60
        # nb_data_keep 10x per second
        fetch_limit=10*interval
        puts "Interval = #{interval}, Uncompressed last #{decal} second"

        # Connect to DB 
        puts 'Connect to DB' 
        DataMapper.setup(:default, $db_url)
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

        Sensor.all.each do |sensor|
            sensor_name=sensor.sensor_hr
            sensor.last_cleaned
            if sensor.last_cleaned.nil?
                from=Time.parse( Measure.last({:sensor => sensor, :order => [:date.desc]}).date.to_s)
            else
                from=Time.parse( sensor.last_cleaned.to_s )
            end
            to=Time.new - 5*60
            puts "[#{sensor_name}]: #{from} => #{to}"

            if(to.to_i - from.to_i < interval) then
                puts "timeframe is not wide enough to fit an interval"
                next
            end
            timeframe = (from.to_i..to.to_i)
            interval_from_sec = timeframe.first
            timeframe.step(interval) do |interval_to_sec|
                # Do not take first value into account
                next if interval_to_sec == timeframe.first
                # Make sure current "from" to current "to" is wider than an interval
                next if interval_to_sec - interval_from_sec < interval.to_i

                # Convert interval_from_sec and interval_to_sec into DateTime
                interval_from_date = Time.at(interval_from_sec)
                interval_to_date = Time.at(interval_to_sec)
                puts "#{sensor_name} => #{interval_to_date}"

                tot = 0
                avg = 0
                ms =  Measure.all({ :sensor => sensor,
                                  :date.gt => interval_from_date,
                                  :date.lt => interval_to_date,
                                  :limit => fetch_limit})

                # Make sure list of measures is not emtpy
                # if it is, return -1 as consumption
                if ms.length == 0
                    m = Measure.new({:date => interval_from_date, :consumption => nil})
                else
                    ms.each { |m| tot = tot + m.consumption }
                    avg = tot / ms.length 
                    m = Measure.new({:date => interval_from_date, :consumption => avg})
                end

                m.save
                ms.destroy
                sensor.attributes= { :last_cleaned => interval_to_date }
                sensor.save
            end
        end
    end

    task :show do
        require 'rubygems'
        require 'dm-core'
        require 'global'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize
        puts %{---}
        puts %{Accounts (#{Account.all.length})}
        Account.all.each do |account|
            puts account.attributes.values.join(' ; ')
        end
        puts %{---}
        puts %{Users (#{User.all.length})}
        User.all.each do |user|
            puts user.attributes.values.join(' ; ')
        end
        puts %{---}
        puts %{Sensors (#{Sensor.all.length})}
        Sensor.all.each do |sensor|
            puts sensor.attributes.values.join(' ; ')
        end
        puts %{---}
        puts %{Measures for John Doe first sensor: johndoe_1}
	sensor = Sensor.first({:sensor_hr => %{johndoe_1}})
        Measure.all({:sensor => sensor}).each do |measure|
            puts measure.attributes.values.join(' ; ')
        end
        puts %{---}
        puts %{Twitter account}
        TwitterAccount.all().each do |a|
            puts a.attributes.values.join(' ; ')
        end
        puts %{---}
        puts %{Facebook account}
        FacebookAccount.all().each do |a|
            puts a.attributes.values.join(' ; ')
        end
    end

    task :populate do
        require 'rubygems'
        require 'dm-core'
        require 'global'
        require 'faker'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

        # User creation
        nb_users=5 # sandrine, filip, yann, luc, johndoe
        (1..nb_users).each do |user_nb|
            if user_nb == 1 then
                firstname, lastname = "John", "Doe"
            elsif user_nb == 2 then
                firstname, lastname = "Sandrine", ""
            elsif user_nb == 3 then
                firstname, lastname = "Filip", ""
            elsif user_nb == 4 then
                firstname, lastname = "Yann", ""
            elsif user_nb == 5 then
                firstname, lastname = "Luc", ""
            end

            puts %{#{firstname} #{lastname}}

            nickname  = %{#{firstname.downcase}#{lastname.downcase}}
	    password = %{#{nickname}123}

            user_hash = {:nickname => "#{nickname}",
                :status   => "Welcome new user" }

            # Get dummy email, country, zip code, city, street
            account_hash = {:firstname => "#{firstname}",
                :lastname  => "#{lastname}",
                :email     => "#{firstname.downcase}.#{lastname.downcase}@yahoo.com",
                :password  => "#{password}",
                :country   => "US",
                :zip       => Faker::Address.zip_code,
                :city      => Faker::Address.city,
                :street    => Faker::Address.street_address}

            # Create user entry
            user = User.new(user_hash)
            user.save

            # Create account entry
            account_hash[:user] = user

            account=Account.new(account_hash)
            account.save

            # Create sensors for each users
            nb_sensors=1
            (1..nb_sensors).each do |sensor_nb|
                sensor=Sensor.new(:sensor_hr        => "#{nickname}_#{sensor_nb}",
                                  :description      => "Sensor #{sensor_nb} of #{firstname} #{lastname}",
                                  :address          => "Same as user",
                                  :user             => user) 
                sensor.save

                # Note: measure creation (for johndoe_1 sensor) should be done using db:add_measures tasks
            end
        end
    end

    # Add history to specified sensor (measures every 5 minutes for 24 hours => 288 measures)
    task :add_measures, :sensor do |t, args|
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'time'

        def min(a,b)
            a<b ? a : b
        end
        def max(a,b)
            a>b ? a : b
        end

        def gaussian_rand (n)
            u1 = u2 = w = g1 = g2 = 0  # declare
            begin
                u1 = 2 * rand - 1
                u2 = 2 * rand - 1
                w = u1 * u1 + u2 * u2
            end while w >= 1

            w = Math::sqrt( ( -2 * Math::log(w)) / w )
            g2 = u1 * w;
            g1 = u2 * w;
            return min(max(0,((g1+4)*n/8)),n)
        end

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	# Measures will be added to specified sensor
	sensor = Sensor.first({:sensor_hr => args.sensor})

	if(sensor.nil?) then 
		puts "Sensor does not exist"
		exit 0
	end

	now=Time.now
	# One measure every 1 minutes
	step=1
	(-2000..2000).each do |i|
		# Get current date
		puts %{#{i} - #{(now + i * 60 * step).to_s}}
		current_date = DateTime.parse( (now + i * 60 * step).to_s )

		# Create random number between 1 and 3000
		consumption = gaussian_rand(3000)

		# Create measure
		measure = Measure.new(:date                => current_date,
				      :consumption         => consumption,
				      :sensor              => sensor)
		puts consumption
		measure.save
	end
    end

    task :fast_add_history do
        require 'rubygems'
        require 'dm-core'
        require 'global'
	    require 'time'

        def min(a,b)
            a<b ? a : b
        end
        def max(a,b)
            a>b ? a : b
        end

        def gaussian_rand (n)
            u1 = u2 = w = g1 = g2 = 0  # declare
            begin
                u1 = 2 * rand - 1
                u2 = 2 * rand - 1
                w = u1 * u1 + u2 * u2
            end while w >= 1

            w = Math::sqrt( ( -2 * Math::log(w)) / w )
            g2 = u1 * w;
            g1 = u2 * w;
            return min(max(0,((g1+4)*n/8)),n)
        end

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	now=Time.now
	# One measure every 1 minutes
	step=1
	(-90..100).each do |i|
		# Get current date
		puts %{#{i} - #{(now + i * 60 * step).to_s}}
		current_date = DateTime.parse( (now + i * 60 * step).to_s )

		# Loop through list of sensors
		Sensor.all.each do |sensor|
			# Create random number between 1 and 3000
			consumption = gaussian_rand(3000)

			# Create measure
			measure = Measure.new(:date                => current_date,
					      :consumption         => consumption,
					      :sensor              => sensor)
            # puts consumption
			measure.save
		end
	end
    end

    task :delete_measures, :sensor do |t, args|
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'time'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	# Measures will be deleted for specified sensor
	sensor = Sensor.first({:sensor_hr => args.sensor})

	if(sensor.nil?) then 
		puts "Sensor does not exist"
		exit 0
	end

	# Delete measures
	Measure.all({:sensor => sensor}).each do |measure|
		measure.destroy
	end
    end

end

namespace "nightly-cron" do
    task :twitter do
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'twitter'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	# Get all entry in Twitter table
	TwitterAccount.all.each do |account|
		# Get user nickname / status
		nickname = account.user.nickname
		status = account.user.status

		# Get sensor
		sensor = Sensor.first({:sensor_hr => "#{nickname}_1"})

		# Get begining of day and beginning of yesterday
		now = DateTime.now
		secs_to_substract = now.hour * 3600 + now.min * 60 + now.sec
		beginning_of_day = DateTime.now - (secs_to_substract/86400.0)
		beginning_of_yesterday = beginning_of_day - 1
		beginning_of_yesterday_s = beginning_of_yesterday.strftime("%d/%m/%y")

		# Get all measures from previous day
		measures = %w{}
        	Measure.all({:sensor => sensor, :date.gt => beginning_of_yesterday, :date.lt => beginning_of_day}).each do |measure|
			measures << measure.consumption
        	end

		# Get average, min, max of measures
		sum, min, max = 0, 999999, 0
		measures.each do |m|
			sum = sum + m
		        min = m if(m<min)
			max = m if(m>max)	
		end

		# Message
		message = %{Date: #{beginning_of_yesterday_s} - Moyenne: #{sum/measures.size}, Min: #{min}, Max: #{max}. # #{status} #}

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
    end
    task :facebook do
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'koala'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	# Get all entry in Facebook table
	FacebookAccount.all.each do |account|
		# Get user nickname
		nickname = account.user.nickname
		status = account.user.status

		# Get sensor
		sensor = Sensor.first({:sensor_hr => "#{nickname}_1"})

		# Get begining of day and beginning of yesterday
		now = DateTime.now
		secs_to_substract = now.hour * 3600 + now.min * 60 + now.sec
		beginning_of_day = DateTime.now - (secs_to_substract/86400.0)
		beginning_of_yesterday = beginning_of_day - 1
		beginning_of_yesterday_s = beginning_of_yesterday.strftime("%d/%m/%y")

		# Get all measures from previous day
		measures = %w{}
        	Measure.all({:sensor => sensor, :date.gt => beginning_of_yesterday, :date.lt => beginning_of_day}).each do |measure|
			measures << measure.consumption
        	end

		# Get average, min, max of measures
		sum, min, max = 0, 999999, 0
		measures.each do |m|
			sum = sum + m
		        min = m if(m<min)
			max = m if(m>max)	
		end

		# Message
		message = %{Date: #{beginning_of_yesterday_s} - Moyenne: #{sum/measures.size}, Min: #{min}, Max: #{max}, # #{status} #}

		# Get key
		access_token=account.access_token

		# Connect
		graph = Koala::Facebook::GraphAPI.new(access_token)

		# Update wall
		graph.put_object("me", "feed", :message => message)
	end
    end
end

namespace "realtime-cron" do
    task :twitter do
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'twitter'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	# Get all entry in Twitter table which need to be published
	TwitterAccount.all({:publish => true}).each do |account|
		# Get user nickname / status
		nickname = account.user.nickname
		status = account.user.status

		# Message
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

		# Set publish flag to false
		account.publish = false
		account.save
	end
    end
    task :facebook do
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'koala'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	# Get all entry in Facebook table
	FacebookAccount.all({:publish => true}).each do |account|
		# Get user nickname
		nickname = account.user.nickname
		status = account.user.status

		# Message
		message = %{Nouveau status: #{status}}

		# Get key
		access_token=account.access_token

		# Connect
		graph = Koala::Facebook::GraphAPI.new(access_token)

		# Update wall
		graph.put_object("me", "feed", :message => message)

		# Set publish flag to false
		account.publish = false
		account.save
	end
    end
end
