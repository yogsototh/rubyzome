require 'rubyzome/controllers/RestController.rb'
require 'time'
class MeasureController < Rubyzome::RestController
	require 'app/controllers/include/Helpers.rb'
	include Helpers
	require 'app/controllers/include/MeasureHelpers.rb'
    include MeasureHelpers
	require 'app/controllers/include/HMeasureHelpers.rb'
    include HMeasureHelpers


    # Get all measure for a given sensor
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures
    def index
        begin
		    check_authentication
		    requestor = get_user(:l)
		    user = get_user
		    check_ownership_requestor_user(requestor,user)
		    sensor = get_sensor
		    check_ownership_user_sensor(user,sensor)

            @fetch_limit=200

            # Get filter params
            from		= @request[:from]
            to	 	    = @request[:to]
            interval 	= @request[:interval]

            # return last measure if from not given
            if from.nil?
                client_date = @request[:refdate]
                if not client_date.nil?
                    @client_offset=DateTime.parse(client_date).offset
                end
                return show_last_measure(sensor)
            end
            
            @client_offset=DateTime.parse(from).offset

            # if only from is given return all values from 'from'
            if to.nil?
                return show_measure_from(sensor,from)
            end

            # Get time for "from" and "to" strings
            from = Time.parse(from)
            to = Time.parse(to)

            # Make sure from date is older than to date
            if(from > to) then
                raise Rubyzome::Error, "\"from\" date must be older than \"to\" date"
            end

            # if from and to given but not interval
            if interval.nil? or interval.to_i <= 0
                return show_measure_from_to(sensor,from,to)
            end
       
            puts "ICI"
            best=nil
            max=0
            History.all({:sensor => sensor}).each do |h|
                puts "H: #{h.interval}"
                if h.interval <= interval.to_i
                    max=h.interval
                    best=h
                end
            end
            if best.nil?
                return show_measure_from_to_with_interval(sensor,from,to,interval)
            else
                return show_hmeasure_from_to_with_interval(best,from,to)
            end
        rescue Exception => e
            puts e.backtrace.join("\n")
            raise Rubyzome::Error, "something went wrong #{e.message}" 
        end
    end

	# Create a new measure for a sensor - Not available (admin action)
	def create
		action_not_available
	end

	# Get measure from measure_hrid
	# curl -i -d'l=login&p=password' -XGET http://gp.loc/sensors/main_home/measures/measure_hr
	# curl -i -d'l=login&p=password' -XGET http://gp.loc/measures/measure_hr
	def show
		check_authentication
		requestor = get_user(:l)
		user = get_user
		check_ownership_requestor_user(requestor,user)
		sensor = get_sensor
		check_ownership_user_sensor(user,sensor)
		measure = get_measure
		check_ownership_sensor_measure(sensor,measure)

		clean_id(measure.attributes)
	end

	# Update measure from measure_hrid - Not available (admin action)
	def update
		action_not_available
	end

	# Delete measure from measure_hrid - Not available (admin action)
	def delete
		action_not_available
	end
end
