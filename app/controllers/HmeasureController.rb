require 'rubyzome/controllers/RestController.rb'
require 'time'
class HmeasureController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers
	require 'app/controllers/include/HMeasureHelpers.rb'
    include HMeasureHelpers


    def index
        begin
        check_authentication
        requestor = get_user(:l)
        user = get_user
		check_ownership_requestor_user(requestor,user)
		sensor = get_sensor
		check_ownership_user_sensor(user,sensor)
        history = get_history
		check_ownership_sensor_history(sensor,history)

        # never fetch more than 200 values at a time
        @fetch_limit=200

        # Get filter params
        from		= @request[:from]
        to	 	    = @request[:to]

        # return last measure if from not given
        if from.nil?
            client_date = @request[:refdate]
            if not client_date.nil?
                @client_offset=DateTime.parse(client_date).offset
            end
            return show_last_hmeasure(history)
        end

        @client_offset=DateTime.parse(from).offset

        # if only from is given return all values from 'from'
        if to.nil?
            return show_hmeasure_from(history,from)
        end

        # Get time for "from" and "to" strings
        from = Time.parse(from)
        to = Time.parse(to)

        # Make sure from date is older than to date
        if(from > to) then
            raise Rubyzome::Error, "\"from\" date must be older than \"to\" date"
        end

        return show_hmeasure_from_to(history,from,to)
        rescue Exception => e
            puts e.backtrace.join("\n")
            return Rubyzome::Error, e.message
        end
    end

    def create
        action_not_available
    end

    def show
		check_authentication
		requestor = get_user(:l)
		user = get_user
		check_ownership_requestor_user(requestor,user)
		sensor = get_sensor
		check_ownership_user_sensor(user,sensor)
        history =  get_history
        check_ownership_sensor_history(sensor,history)
        hmeasure =  get_hmeasure
        check_ownership_history_hmeasure(history,hmeasure)

        clean_id(hmeasure.attributes)
    end

    def update
        action_not_available
    end

    def delete
        action_not_available
    end
end
