require 'date'
module MeasureHelpers

    def server_offset
        if @server_offset.nil?
            @server_offset=DateTime.now.offset
        end
        return @server_offset
    end

    def client_to_server_timezone(date)
        if @client_offset.nil?
            return date
        end
        hour_offset=(@client_offset - server_offset)*24
        time=Time.parse( DateTime.parse(date.to_s).to_s )
        return DateTime.parse( ( time - (hour_offset*60*60) ).to_s )
    end

    def to_client_timezone(date)
        if @client_offset.nil?
            return date.to_s
        else
            # hour_offset=(@client_offset - server_offset)*24
            # time=Time.parse( DateTime.parse(date.to_s).to_s )
            # res=DateTime.parse( ( time - (hour_offset*60*60) ).to_s )
            # res=res.new_offset(@client_offset)
            #return res.strftime("%Y-%m-%dT%H:%M:%S%z")
            return DateTime.parse(date.to_s).new_offset(@client_offset).strftime("%Y-%m-%dT%H:%M:%S%z")
        end
    end

    def encapsulate(measures, interval = 0 )
        if measures.nil? or measures.length == 0
            return {
                'from'		=> nil,
                'to'		=> nil,
                'max'		=> 0,
                'interval'	=> interval.to_i,
                'data'		=> [],
            }
        end

        localFrom=to_client_timezone(measures[0].date)
        localTo=to_client_timezone(measures[-1].date)
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
