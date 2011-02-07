module HMeasureHelpers
    def encapsulate(hmeasures)
        if hmeasures.size == 0 or ( hmeasures.size == 1 and hmeasures[0] == nil )
            return {
                'from'		=> nil,
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
        return encapsulate( [ HMeasure.last({:history => history, :date.lt => DateTime.now} )])
    end

    def show_hmeasure_from(history, from) 
        return encapsulate(HMeasure.all({:history => history, :date.gt => from, :limit => @fetch_limit}))
    end

    def show_hmeasure_from_to(history,from,to)
        return encapsulate(HMeasure.all({:history => history, :date.gt => from, :date.lt => to, :limit => @fetch_limit}))
    end

end
