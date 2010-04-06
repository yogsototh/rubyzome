require 'rubyzome/controllers/RestController.rb'
require 'time'
class MeasureController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Get all measure for a given sensor
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures
    def index
        check_authentication
        sensor = get_sensor

        # Get filter params
        from		= @request[:from]
        to	 	    = @request[:to]
        interval 	= @request[:interval]

        # If from and to are provided 		=> get measures within this timeframe
        # If only from is provided 		=> get all measures created after this date
        # If from and to are not provided 	=> only get the last created measure
        if(not from.nil?) then
            # List of measures to be returned
            measures = []
            period = 0

            if(not to.nil?) then
                # Make sure from date is older than to date
                if(from > to) then
                    raise Rubyzome::Error, "\"from\" date must be older than \"to\" date"
                end

                if not interval.nil? then
                    # Interval specified (number of sec) => measure average calculated
                    period = interval.to_i	

                    # Get time for "from" and "to" strings
                    from = Time.parse(from)
                    to = Time.parse(to)

                    # Make sure timeframe (from..to) is wider than an interval
                    if(to.to_i - from.to_i < interval.to_i) then
                        raise Rubyzome::Error, "timeframe is not wide enough to fit an interval"
                    end

                    # Split timeframe (from..to) into timeframes of "interval" length
                    timeframe = (from.to_i..to.to_i)
                    interval_from_sec = timeframe.first
                    timeframe.step(interval.to_i) do |interval_to_sec|
                        # Do not take first value into account
                        next if interval_to_sec == timeframe.first

                        # Make sure current "from" to current "to" is wider than an interval
                        next if interval_to_sec - interval_from_sec < interval.to_i

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
                else
                    measures = Measure.all({:sensor => sensor, :date.gt => from, :date.lt => to})
                end
            else
                measures = Measure.all({:sensor => sensor, :date.gt => from})
            end

            # Make sure list of measures is not emtpy
            raise Rubyzome::Error, "No data for this timeframe" unless(measures.length > 0)

            # Add values to be returned
            # start date 	=> date of the first measure
            # end date	=> date of the last measure
            # max		=> max value
            # interval
            {
                'from'		=> measures[0].date,
                'to'		=> measures[-1].date,
                'max'		=> measures.map{ |m| m.consumption }.max,
                'interval'	=> period,
                'data'		=> measures.map{ |x| clean_id(x.attributes) },
            }
        else
            measure = Measure.last({:sensor => sensor, :date.lt => DateTime.now})
            clean_id(measure.attributes)
        end
    end

    # Create a new measure for a sensor
    # curl -i -XPOST -d'l=login&p=pass&consumption=3434' http://gpadm.loc/sensors/main_home/measures
    # curl -i -XPOST -d'l=login&p=pass&consumption=3434' http://gpadm.loc/measures
    def create
        check_authentication
        sensor = get_sensor

        begin
            measure = Measure.new( clean_hash([:consumption])  )
            measure.sensor = sensor
            measure.save
        rescue Exception => e
            raise Rubyzome::Error, "Cannot create new measure: #{e.message}"
        end

        clean_id(measure.attributes)
    end

    # Get measure from measure_hrid
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures/measure_hr
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/measures/measure_hr
    def show
        check_authentication
        sensor =  get_sensor
        measure =  get_measure
        check_ownership_sensor_measure(sensor,measure)

        clean_id(measure.attributes)
    end

    # Update measure from measure_hr
    # curl -i -XPUT -d'l=login&p=pass&consumption=cons' http://gpadm.loc/sensors/main_home/measures/measure_hr
    # curl -i -XPUT -d'l=login&p=password&consumption=cons' http://gpadm.loc/measures/measure_hr
    def update
        check_authentication
        sensor =  get_sensor
        measure =  get_measure
        check_ownership_sensor_measure(sensor,measure)

        begin
            measure.consumption = hash[:consumption]
            measure.save
        rescue
            raise Rubyzome::Error, "Cannot update measure: #{e.message}"
        end

        clean_id(measure.attributes)
    end


    # Delete measure from measure_hrid 
    # curl -i -XDELETE -d'l=login&p=pass' http://gpadm.loc/measures/measure_hr
    # curl -i -XDELETE -d'l=login&p=pass' http://gpadm.loc/sensors/main_home/measures/measure_hr
    def delete
        check_authentication
        sensor =  get_sensor
        measure =  get_measure
        check_ownership_sensor_measure(sensor,measure)

        begin
            measure.destroy
        rescue Exception => e
            raise Rubyzome::Error, "Cannot delete measure: #{e.message}"
        end

        action_completed("Measure #{measure.measure_hr} deleted")
    end
end
