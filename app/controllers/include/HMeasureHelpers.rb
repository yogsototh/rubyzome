module HMeasureHelpers
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

    def encapsulate(hmeasures,interval=0)
        if hmeasures.size == 0 or ( hmeasures.size == 1 and hmeasures[0] == nil )
            return {
                'from'		=> nil,
                'interval'  => interval,
                'to'		=> nil,
                'max'		=> nil,
                'data'		=> [],
            }
        end
        if @client_offset.nil?
            localFrom=hmeasures[0].date.to_s
            localTo=hmeasures[-1].date.to_s
        else
            localFrom=DateTime.parse(hmeasures[ 0].date.to_s).
                new_offset(@client_offset).strftime("%Y-%m-%dT%H:%M:%S%z")
            localTo=  DateTime.parse(hmeasures[-1].date.to_s).
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
                'max'		=> hmeasures.map{ |m| m.consumption }.max,
                'data'		=> hmeasures.map{ |x| x.consumption },
            }
        else
            return {
                'from'		=> hmeasures[0].date,
                'to'		=> hmeasures[-1].date,
                'max'		=> hmeasures.map{ |m| m.consumption }.max,
                'data'		=> hmeasures.map{ |x| clean_id(x.attributes) },
            }
        end
    end

    def show_last_hmeasure(history)
        return show_measure_from_to_with_interval(history, (Time.now - history.interval*( @fetch_limit - 1)).to_datetime, DateTime.now )
    end

    def show_hmeasure_from(history, from) 
        return show_measure_from_to_with_interval(history,from,DateTime.now)
    end

    def show_hmeasure_from_to(history,from,to)
        return show_measure_from_to_with_interval(history,from,to)
    end

    def show_measure_from_to_with_interval(history,from,to)
        # Make sure timeframe (from..to) is wider than an interval
        to=Time.parse( client_to_server_timezone(to).to_s )
        from=Time.parse( client_to_server_timezone(from).to_s )
        ito=to.to_i
        ifrom=from.to_i
        iint=history.interval

        if (ito - ifrom < iint) then
            raise Rubyzome::Error, "timeframe is not wide enough to fit an interval"
        end
        if ((ito - ifrom) / iint) > @fetch_limit then
            raise Rubyzome::Error, "Too much datas requested"
        end

        ms = HMeasure.all({ :history => history,
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
                    measures <<= HMeasure.new({:date => next_step, :consumption => sum/nb})
                end
                next_step += iint
                while t > next_step
                    measures <<= HMeasure.new({:date => next_step, :consumption => -1})
                    next_step += iint
                end
                sum=m.consumption
                nb=1
            end
        end

        encapsulate(measures, iint)
    end

end
