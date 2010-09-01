namespace "db" do

    task :init do
	Rake.application.invoke_task("db:init")
    end

    task :init_action do |t|
	require 'rubygems'
	require 'dm-core'
	require 'dm-migrations'
	require 'faker'

	# Connect to DB 
	DataMapper.setup(:default, $db_url)
	# Include all models
	Dir["app/models/*.rb"].each { |file| require file }
	# Reset tables
	DataMapper.finalize
	DataMapper.auto_migrate!

	# User creation
	nb_users=10
	(1..nb_users).each do |user_nb|
		# Get dummy 
		# - firstname
		# - lastname
		# - email
		# - nickname 

		# Variables declaration
		firstname, lastname, nickname = nil, nil, nil

		# First user will be set to John Doe / johndoe
		if user_nb == 1 then
			firstname = "John"
			lastname = "Doe"
			nickname = "johndoe"
		else
			firstname         = Faker::Name.first_name
			lastname         = Faker::Name.last_name
			nickname        = "#{firstname.downcase}#{lastname.downcase}"
		end

		user_hash = { :nickname        => "#{nickname}" }

		account_hash = { :firstname        => "#{firstname}",
				 :lastname         => "#{lastname}",
				 :email                => "#{firstname.downcase}.#{lastname.downcase}@yahoo.com",
				 :password        => "guest"}

		# Create user entry
		user = User.new(user_hash)
		user.save

		# Create account entry
		account_hash[:user] = user
        
		account=Account.new(account_hash)
		account.save

		# Create trackers for each users
		nb_trackers=3
		(1..nb_trackers).each do |tracker_nb|
			tracker = Tracker.new(  :tracker_hr          => "#{nickname}_#{tracker_nb}",
						:phoneNumber         => "0123456789",
						:user                => user) 
			tracker.save
			# Create location for each tracker
			nb_location=10
			total = 0
			(1..nb_location).each do |location_nb|
				d = Time.now - location_nb * 5 * 60
				location = Location.new(:date => d,
							:latitude => 21.3,
							:longitude => 2.4,
							:altitude => 300.4,
							:tracker => tracker)
				location.save
			end	
		end	
	end	
    end
end
