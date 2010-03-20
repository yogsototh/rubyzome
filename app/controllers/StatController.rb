require 'rubyzome/controllers/ServiceRestController.rb'
require 'date'
require 'time'

class StatController < ServiceRestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

   def services
        {        
                :index => [:min,:max,:last,:average,:history],
                :show  => [:min,:max,:last,:average,:history]
        }
   end

   # curl -i -XGET 'l=login&p=pass' http://gp.loc/users/user1/sensors/sensor1/stats.xml
   # curl -i -XGET 'l=login&p=pass' http://gp.loc/users/user1/sensors/sensor1/stats/history.xml
   def history
        check_authentication
        user = get_user
        sensor = get_sensor
        check_ownership_user_sensor(user,sensor)
        start_date = get_start_date

        # Get measures created after start date for the given sensor
        measures = Measure.all({:sensor => sensor, :date.gt => start_date})
        if(measures.length > 0)
                measures.map do |x|
                        {
                        :date => x.date,
                        :consumption => x.consumption
                        }
                end
        else
                raised GridError, "No measure found for this period"
        end
   end

   def average
        check_authentication
        user = get_user
        sensor = get_sensor
        check_ownership_user_sensor(user,sensor)
        start_date = get_start_date

        # Get all measures for given sensor
        m = 0
        measures = Measure.all({:sensor => sensor, :date.gt => start_date})
        if(measures.length > 0) then
                measures.each { |x| m = m + x.consumption.to_f }
                m = m / measures.length
                {:average => m}
        else
                raise GridError, "No measure found for this period"
        end
   end

   def min
        check_authentication
        user = get_user
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
                raise GridError, "No measure found for this period"
        end
   end

   def max
        check_authentication
        user = get_user
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
                raise GridError, "No measure found for this period"
        end
   end

   def last
        check_authentication
        user = get_user
        sensor = get_sensor
        check_ownership_user_sensor(user,sensor)

        # Get last measure for the given sensor
        measure = Measure.last({:sensor => sensor, :date.lt => Time.now})
        if(not measure.nil?) then
		m = measure.consumption.to_i
		{:last => m}
        else
                raise GridError, "No measure found for this period"
        end
   end
end
