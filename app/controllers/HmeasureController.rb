require 'rubyzome/controllers/RestController.rb'
require 'time'
class HmeasureController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers
	require 'app/controllers/include/HMeasureHelpers.rb'
    include HMeasureHelpers


    def index
        check_authentication
        history = get_history

        # never fetch more than 200 values at a time
        @fetch_limit=200

        # Get filter params
        from		= @request[:from]
        to	 	    = @request[:to]

        # return last measure if from not given
        if from.nil?
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
    end

    def create
        check_authentication
        history = get_history

        check_mandatory_params([:consumption])
        begin
            new_hmeasure_values= clean_hash([:consumption])
            if @request[:date].nil?
                new_hmeasure_values[:date]=DateTime.now
            else
                new_hmeasure_values[:date]=@request[:date]
            end
            hmeasure = HMeasure.new( new_hmeasure_values )
            hmeasure.history = history
            hmeasure.save
        rescue Exception => e
            raise Rubyzome::Error, "Cannot create new hmeasure: #{e.message}"
        end

        clean_id(hmeasure.attributes)
    end

    def show
        check_authentication
        history =  get_history
        hmeasure =  get_hmeasure
        check_ownership_history_hmeasure(history,hmeasure)

        clean_id(hmeasure.attributes)
    end

    def update
        check_authentication
        history =  get_history
        hmeasure =  get_hmeasure
        check_ownership_history_hmeasure(history,hmeasure)

        begin
            hmeasure.consumption = hash[:consumption]
            hmeasure.save
        rescue
            raise Rubyzome::Error, "Cannot update measure: #{e.message}"
        end

        clean_id(hmeasure.attributes)
    end

    def delete
        check_authentication
        history =  get_history
        hmeasure =  get_hmeasure
        check_ownership_history_hmeasure(history,hmeasure)

        begin
            hmeasure.destroy
        rescue Exception => e
            raise Rubyzome::Error, "Cannot delete hmeasure: #{e.message}"
        end

        action_completed("Measure #{hmeasure.measure_hr} deleted")
    end
end
