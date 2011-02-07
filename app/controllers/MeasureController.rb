require 'rubyzome/controllers/RestController.rb'
require 'time'
require 'app/controllers/include/DateHelper.rb'
class MeasureController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers
	require 'app/controllers/include/MeasureHelpers.rb'
    include MeasureHelpers


    # Get all measure for a given sensor
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures
    def index
        check_authentication
        sensor = get_sensor

        # never fetch more than 200 values at a time
        @fetch_limit=200

        # Get filter params
        from		= @request[:from]
        to	 	    = @request[:to]
        interval 	= @request[:interval]

        # return last measure if from not given
        if from.nil?
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

        return show_measure_from_to_with_interval(sensor,from,to,interval)
    end

    # Create a new measure for a sensor
    # curl -i -XPOST -d'l=login&p=pass&consumption=3434' http://gpadm.loc/sensors/main_home/measures
    # curl -i -XPOST -d'l=login&p=pass&consumption=3434' http://gpadm.loc/measures
    def create
        check_authentication
        sensor = get_sensor

        begin
            new_measure_values= clean_hash([:consumption])
            if @request[:date].nil?
                new_measure_values[:date]=DateTime.now
            else
                new_measure_values[:date]=@request[:date]
            end
            measure = Measure.new( new_measure_values )
            measure.sensor = sensor
            measure.save
            update_history(sensor,measure)
        rescue Exception => e
            puts e.backtrace.join("\n")
            raise Rubyzome::Error, "Cannot create new measure: #{e.message}"
        end

        clean_id(measure.attributes)
    end

    def update_history(sensor,last_measure)
        @fetch_limit=200
        last_measure_date = last_measure[:date]
        last_measure_time=Time.parse( last_measure_date.to_s )
        sensor.history.each do |h|
            hml = h.measure.last
            interval  = h.interval
            if hml.nil?
                last_history_date = DateTime.parse("01/01/1970")
            else
                last_history_date = hml.date
            end
            last_history_time = Time.parse( last_history_date.to_s )
            puts "#{interval - last_measure_time.to_i + last_history_time.to_i} sec before update history"
            if last_measure_time - last_history_time  > interval
                n=Time.now
                last_history_time = n - interval - n.to_i%interval
                last_history_date = last_history_time.to_datetime
                puts "Active update for #{h.name}"
                to   = ( last_history_date.to_time + interval ).to_datetime
                from = last_history_date
                measures = Measure.all({:sensor => sensor, 
                                       :date.gt => from, 
                                       :date.lt => to, 
                                       :limit => @fetch_limit})
                sum=0
                last_date=nil
                last_time=last_history_time
                measures.each do |m|
                    new_time = Time.parse( m[:date].to_s )
                    duration = new_time - last_time
                    last_time = new_time
                    sum+=m[:consumption]*duration
                end
                sum /= interval
                measure=HMeasure.new({
                            :date => to, 
                            :consumption => sum})
                measure.history = h
                measure.save
            end
        end
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
