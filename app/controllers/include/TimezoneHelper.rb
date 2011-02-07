module TimezoneHelper
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
end
