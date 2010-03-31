require 'rubyzome/controllers/RestController.rb'
require 'time'
class MeasureController < Rubyzome::RestController
	require 'app/controllers/include/Helpers.rb'
	include Helpers


	# Get all measure for a given sensor
	# curl -i -d'l=login&p=password' -XGET http://gp.loc/sensors/main_home/measures
	def index
		check_authentication
		requestor = get_user(:l)
		user = get_user
		check_ownership_requestor_user(requestor,user)
		sensor = get_sensor
		check_ownership_user_sensor(user,sensor)

                # Get filter params
                from            = @request[:from]
                to              = @request[:to]
                interval        = @request[:interval]

                # If from and to are provided           => get measures within this timeframe
                # If only from is provided              => get all measures created after this date
                # If from and to are not provided       => only get the last created measure
                if(not from.nil?) then
                        if(not to.nil?) then
                                # Make sure from date is older than to date
                                if(from > to) then
                                        raise Rubyzome::Error, "\"from\" date must be older than \"to\" date"
                                end

                                if not interval.nil? then
                                        # Interval specified (number of sec) => measure average calculated

                                        # Get time for "from" and "to" strings
                                        from = Time.parse(from)
                                        to = Time.parse(to)

                                        # Make sure timeframe (from..to) is wider than an interval
                                        if(to.to_i - from.to_i < interval.to_i) then
                                                raise Rubyzome::Error, "timeframe is not wide enough to fit an interval"
                                        end

                                        # List that will handle measures average
                                        measures = []

                                        # Split timeframe (from..to) into timeframes of "interval" length
                                        timeframe = (from.to_i..to.to_i)
                                        interval_from_sec = timeframe.first
                                        timeframe.step(interval.to_i) do |interval_to_sec|
                                                # Do not take first value into account
                                                next if interval_to_sec == timeframe.first
                                                # Convert interval_from_sec and interval_to_sec into DateTime
                                                interval_from_date = Time.at(interval_from_sec)
                                                interval_to_date = Time.at(interval_to_sec)

                                                tot = 0
                                                avg = 0
                                                ms =  Measure.all({ :sensor => sensor,
                                                                         :date.gt => interval_from_date,
                                                                         :date.lt => interval_to_date})
                                                ms.each { |m| puts m.attributes;tot = tot + m.consumption }
                                                avg = tot / ms.length if ms.length != 0
                                                m = Measure.new({:date => interval_from_date, :consumption => avg})
                                                measures << m

                                                interval_from_sec = interval_to_sec
                                        end
                                        if measures.length > 0 then
                                                measures.map{ |x| clean_id(x.attributes) }
                                        else
                                                raise Rubyzome::Error, "No data for this time frame"
                                        end
                                else
                                        Measure.all({:sensor => sensor, :date.gt => from, :date.lt => to}).map{ |x| clean_id(x.attributes) }
                                end
                        else
                                Measure.all({:sensor => sensor, :date.gt => from}).map{ |x| clean_id(x.attributes) }
                        end
                else
                        measure = Measure.last({:sensor => sensor, :date.lt => DateTime.now})
                        clean_id(measure.attributes)
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
