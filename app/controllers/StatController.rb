require 'rubyzome/controllers/ServiceRestController.rb'
require 'date'
require 'time'

class StatController < Rubyzome::ServiceRestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

   def services
	{	
		:index => [:min,:max,:average,:historic],
     		:show  => [:min,:max,:average,:historic]
	}
   end

   # curl -i -XGET 'l=login&p=pass' http://gp.loc/users/user1/sensors/sensor1/stats.xml
   # curl -i -XGET 'l=login&p=pass' http://gp.loc/users/user1/sensors/sensor1/stats/historic.xml
   def historic
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)
	start_date = get_start_date

	# Get measures created after start date for the given sensor
	measures = Measure.all({:sensor => sensor, :date.gt => start_date})
	if(measures.length > 0)
		measures.map do |x|
			{
			:date		=> x.date,
			:consumption	=> x.consumption
			}
		end
	else
		raise Rubyzome::Error, "No measure found for this period"
	end
   end

   def average
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)
	start_date = get_start_date

	# Get measures created after start date for the given sensor
	measures = Measure.all({:sensor => sensor, :date.gt => start_date})
	if(measures.length > 0)
		m=0
		measures.each { |x| m = m + x.consumption.to_f }
		m = m / measures.length
		{:average => m}
	else
		raise Rubyzome::Error, "No measure found for this period"
	end
   end

   def min
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)
	start_date = get_start_date

	# Get measures created after start date for the given sensor
	measures = Measure.all({:sensor => sensor, :date.gt => start_date})
	if(measures.length > 0)
		m = measures[0].consumption.to_i
		measures.each { |x| m = x.consumption.to_i if m > x.consumption.to_i }
		{:min => m}
	else
		raise Rubyzome::Error, "No measure found for this period"
	end
   end

   def max
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)
	start_date = get_start_date

	# Get measures created after start date for the given sensor
	measures = Measure.all({:sensor => sensor, :date.gt => start_date})
	if(measures.length > 0)
		m = measures[0].consumption.to_i
		measures.each { |x| m = x.consumption.to_i if m < x.consumption.to_i }
		{:max => m}
	else
		raise Rubyzome::Error, "No measure found for this period"
	end
   end
end
