require 'rubyzome/controllers/RestController.rb'
require 'time'
class MeasureController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    def encapsulate(measures, interval = 0 )
        {
            'from'		=> measures[0].date,
            'to'		=> measures[-1].date,
            'max'		=> measures.map{ |m| m.consumption }.max,
            'interval'	=> interval.to_i,
            'data'		=> measures.map{ |x| clean_id(x.attributes) },
        }
    end

    # Get all measure for a given sensor
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures
    def index
        check_authentication
        sensor = get_sensor

        # Get filter params
        from		= @request[:from]
        to	 	    = @request[:to]
        interval 	= @request[:interval]

        # return last measure if from not given
        if from.nil?
            return encapsulate(Measure.last({:sensor => sensor, :date.lt => DateTime.now}))
        end

        # if only from is given return all values from 'from'
        if to.nil?
            return encapsulate(Measure.all({:sensor => sensor, :date.gt => from}))
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
            return encapsulate(Measure.all({:sensor => sensor, :date.gt => from, :date.lt => to}))
        end

        # Make sure timeframe (from..to) is wider than an interval
        if(to.to_i - from.to_i < interval.to_i) then
            raise Rubyzome::Error, "timeframe is not wide enough to fit an interval"
        end

        # Split timeframe (from..to) into timeframes of "interval" length
        timeframe = (from.to_i..to.to_i)
        interval_from_sec = timeframe.first
        measures=[]
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

            # Make sure list of measures is not emtpy
            # if it is, return -1 as consumption
            if ms.length == 0
                m = Measure.new({:date => interval_from_date, :consumption => -1})
                measures << m
                next
            end

            ms.each { |m| tot = tot + m.consumption }
            avg = tot / ms.length 
            m = Measure.new({:date => interval_from_date, :consumption => avg})
            measures << m

            interval_from_sec = interval_to_sec
        end
        encapsulate(measures, interval)
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
