namespace "db" do

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

	# Comment that could be added by admin, based on user average consumption
	comments =         {
		0..500                => "Very low consumption",
                501..1000        => "Low consumption",
                1001..1500        => "Normal consumption",
                1501..2000        => "Medium consumption",
                2001..2500        => "Consumption quite high",
                2501..3000        => "High consumption, please reduce it :-)"
	}

	# User creation
	nb_users=10
	(1..nb_users).each do |user_nb|
		# Get dummy 
		# - firstname
		# - lastname
		# - email
		# - nickname 
		# - country
		# - zip code
		# - city
		# - street

		firstname = Faker::Name.first_name
		lastname  = Faker::Name.last_name

		# Add 2 easy to remember users for testing purposes
		if user_nb == 1 then
			firstname= "John"
			lastname = "Doe"
		elsif user_nb == 2 then
			firstname = "Jack"
			lastname = "Blue"
		end

		nickname  = "#{firstname.downcase}#{lastname.downcase}"

		user_hash = {:nickname => "#{nickname}",
			     :status   => "" }

		account_hash = {:firstname => "#{firstname}",
				:lastname  => "#{lastname}",
				:email     => "#{firstname.downcase}.#{lastname.downcase}@yahoo.com",
				:password  => "guest",
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
		nb_sensors=3
		(1..nb_sensors).each do |sensor_nb|
			sensor=Sensor.new(:sensor_hr        => "#{nickname}_#{sensor_nb}",
					  :description         => "Sensor #{sensor_nb} of #{firstname} #{lastname}",
                                          :address         => "Same as user",
                                          :user                 => user) 
			sensor.save

			# Create measure for each sensor: one measure each 30 minutes for the past 2 days
			nb_measures=96
			total = 0
			(1..nb_measures).each do |measure_nb|
				d = Time.now - measure_nb * 5 * 60
				measure = Measure.new(:date => d,
                                                      :consumption => rand(3000),
                                                      :sensor => sensor)
				measure.save
				total = total + measure.consumption.to_f
			end

			# Get measure average
			average = total / nb_measures

			# Set comment to  user depending upon his average consumption
			comment = ""
			comments.each do |k,v|
				if k.include?(average) then
					comment = v
				end
			end
			user.status = comment
			user.save
		end
	end
    end

    # Add one day history (measures every 5 minutes for 24 hours => 288 measures per sensor)
    task :add_history do
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'time'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	now=Time.now
	# One measure every 5 minutes
	step=5
	(-288..0).each do |minutes|
		# Get current date
		current_date = DateTime.parse( (now + minutes * 60 * step).to_s )

		# Loop through list of sensors
		Sensor.all.each do |sensor|
			# Create random number between 1000 and 3000
			consumption = rand(3000)

			# Create measure
			measure = Measure.new(:date                => current_date,
					      :consumption         => consumption,
					      :sensor              => sensor)
			measure.save
		end
	end
    end

    task :delete_measures do
        require 'rubygems'
        require 'dm-core'
        require 'global'
	require 'time'

        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        DataMapper.finalize

	# Delete measures
	Measure.all.each do |measure|
		measure.destroy
	end
    end

end
