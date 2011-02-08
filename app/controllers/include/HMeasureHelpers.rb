require 'date'
module HMeasureHelpers
    require 'app/controllers/include/TimezoneHelper.rb'
    include TimezoneHelper

    def show_last_hmeasure(history)
        return show_hmeasure_from_to_with_interval(history, (Time.now - history.interval*( @fetch_limit - 1)).to_datetime, DateTime.now )
    end

    def show_hmeasure_from(history, from) 
        return show_hmeasure_from_to_with_interval(history,from,DateTime.now)
    end

    def show_hmeasure_from_to(history,from,to)
        return show_hmeasure_from_to_with_interval(history,from,to)
    end

    def show_hmeasure_from_to_with_interval(history,from,to)
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
            raise Rubyzome::Error, %{Too much datas requested : #{(ito -ifrom) / iint}. Please use a wider interval or a shorter 'to - from' duration.}
        end

        ms = HMeasure.all({ :history => history,
                            :date.gt => from,
                            :date.lt => to,
                            :limit => @fetch_limit})

        hmeasures=[]
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
                    hmeasures <<= HMeasure.new({:date => next_step, :consumption => sum/nb})
                end
                next_step += iint
                while t > next_step
                    hmeasures <<= HMeasure.new({:date => next_step, :consumption => -1})
                    next_step += iint
                end
                sum=m.consumption
                nb=1
            end
        end

        encapsulate(hmeasures, iint)
    end

end
