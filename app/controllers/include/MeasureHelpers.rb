require 'date'
module MeasureHelpers
    require 'app/controllers/include/TimezoneHelper.rb'
    include TimezoneHelper


    def show_last_measure(sensor)
        return encapsulate( [ Measure.last({:sensor => sensor, :date.lt => DateTime.now} )])
    end

    def show_measure_from(sensor, from) 
        from=client_to_server_timezone(from)
        return encapsulate(Measure.all({:sensor => sensor, :date.gt => from, :limit => @fetch_limit}))
    end

    def show_measure_from_to(sensor,from,to)
        from=client_to_server_timezone(from)
        to=client_to_server_timezone(to)
        return encapsulate(Measure.all({:sensor => sensor, :date.gt => from, :date.lt => to, :limit => @fetch_limit}))
    end

    def show_measure_from_to_with_interval(sensor,from,to,interval)
        # Make sure timeframe (from..to) is wider than an interval
        to=Time.parse( client_to_server_timezone(to).to_s )
        from=Time.parse( client_to_server_timezone(from).to_s )
        ito=to.to_i
        ifrom=from.to_i
        iint=interval.to_i

        if (ito - ifrom < iint) then
            raise Rubyzome::Error, "timeframe is not wide enough to fit an interval"
        end
        if ((ito - ifrom) / iint) > @fetch_limit then
            raise Rubyzome::Error, "Too much datas requested"
        end

        ms =  Measure.all({ :sensor => sensor,
                            :date.gt => from,
                            :date.lt => to,
                            :limit => @fetch_limit})

        measures=[]
        next_step=from + iint
        sum=0
        nb=0
        ms.each do |m|
            # puts %{#{m.consumption}\t#{next_step}\t#{m.date}\t#{sum}}
            t=Time.parse( m.date.to_s)
            if t < next_step
                sum+=m.consumption
                nb+=1
            else
                if nb>0
                    measures <<= Measure.new({:date => next_step, :consumption => sum/nb})
                end
                next_step += iint
                while t > next_step
                    measures <<= Measure.new({:date => next_step, :consumption => -1})
                    next_step += iint
                end
                sum=m.consumption
                nb=1
            end
        end

        encapsulate(measures, interval)
    end
end
