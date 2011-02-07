require 'rubyzome/controllers/RestController.rb'
class HistoryController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Get all history objects for a given sensor
    def index
	    check_authentication
	    user = get_user
        sensor = get_sensor
        History.all({:sensor => sensor}).map do |x| 
		    clean_id(x.attributes)
        end
    end

    def create
	    check_authentication
        user=get_user
        sensor=get_sensor
        check_mandatory_params([:interval,:name])
        begin
            history=History.new(clean_hash([:interval,:name]))
            history.sensor = sensor
            history.save
        rescue Exception => e
            raise Rubyzome::Error, "Cannot create history: #{e.message}"
        end
        clean_id(history.attributes)
    end

    def show
	    check_authentication
	    user = get_user
	    sensor = get_sensor
	    check_ownership_user_sensor(user,sensor)
        history = get_history
	    clean_id(history.attributes)
    end

    def update
	    action_not_available
    end

    def delete
	    action_not_available
    end
end
