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
        nb_users=2
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

            puts %{#{firstname} #{lastname}}

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
	# One measure every 5 minutes
	step=5
	(-2000..2000).each do |i|
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
            puts consumption
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
