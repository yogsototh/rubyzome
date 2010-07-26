require 'rubyzome/controllers/ServiceRestController.rb'
require 'time'

class MobileController < Rubyzome::ServiceRestController
   require 'app/controllers/include/Helpers.rb'
   include Helpers

   def services
	{	
		:index => [:info],
     		:show  => [:info]
	}
   end

    def encapsulate(measures, status, interval = 0)
        {
            'from'		=> measures[0].date.strftime("%Y-%m-%dT%H:%M:%S%z"),
            'to'		=> measures[-1].date.strftime("%Y-%m-%dT%H:%M:%S%z"),
            'max'		=> measures.map{ |m| m.consumption }.max,
            'interval' 		=> interval.to_i,
            'data'		=> measures.map{ |x| x.consumption },
	    'status'		=> status
        }
    end

    # Get all measure for a given sensor
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures
    def info
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)

        # Get filter params
	nickname	= @request[:l]
        from		= @request[:from]
        to	 	= @request[:to]
        interval 	= @request[:interval]

	# Get status
	status = User.first({:nickname => nickname}).status;

        # return last measure if from not given
        if from.nil?
            return encapsulate( [ Measure.last({:sensor => sensor, :date.lt => DateTime.now} )], status)
        end

        # if only from is given return all values from 'from'
        if to.nil?
            return encapsulate(Measure.all({:sensor => sensor, :date.gt => from}), status)
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
            return encapsulate(Measure.all({:sensor => sensor, :date.gt => from, :date.lt => to}), status)
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
            else
                ms.each { |m| tot = tot + m.consumption }
                avg = tot / ms.length 
                m = Measure.new({:date => interval_from_date, :consumption => avg})
                measures << m
            end

            interval_from_sec = interval_to_sec
        end

        encapsulate(measures, status, interval)
    end
end
