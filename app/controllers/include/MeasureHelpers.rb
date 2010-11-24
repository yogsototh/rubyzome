module MeasureHelpers
    def encapsulate(measures, interval = 0 )
        if @client_offset.nil?
            localFrom=measures[0].date.to_s
            localTo=measures[-1].date.to_s
        else
            localFrom=DateTime.parse(measures[ 0].date.to_s).
                new_offset(@client_offset).strftime("%Y-%m-%dT%H:%M:%S%z")
            localTo=  DateTime.parse(measures[-1].date.to_s).
                new_offset(@client_offset).strftime("%Y-%m-%dT%H:%M:%S%z")
        end
        if @version.nil?
            if not @request[:v].nil?
                @version=@request[:v].to_i
            else
                @version=1
            end
        end
        if @version>1
            return {
                'from'		=> localFrom,
                'to'		=> localTo,
                'max'		=> measures.map{ |m| m.consumption }.max,
                'interval'	=> interval.to_i,
                'data'		=> measures.map{ |x| x.consumption },
            }
        else
            return {
                'from'		=> measures[0].date,
                'to'		=> measures[-1].date,
                'max'		=> measures.map{ |m| m.consumption }.max,
                'interval'	=> interval.to_i,
                'data'		=> measures.map{ |x| clean_id(x.attributes) },
            }
        end
    end

    def show_last_measure(sensor)
        return encapsulate( [ Measure.last({:sensor => sensor, :date.lt => DateTime.now} )])
    end

    def show_measure_from(sensor, from) 
        return encapsulate(Measure.all({:sensor => sensor, :date.gt => from, :limit => @fetch_limit}))
    end

    def show_measure_from_to(sensor,from,to)
        return encapsulate(Measure.all({:sensor => sensor, :date.gt => from, :date.lt => to, :limit => @fetch_limit}))
    end

    def show_measure_from_to_with_interval(sensor,from,to,interval)
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
                              :date.lt => interval_to_date,
                              :limit => @fetch_limit})

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
        encapsulate(measures, interval)
    end
end
