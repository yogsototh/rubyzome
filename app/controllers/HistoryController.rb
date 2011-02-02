require 'rubyzome/controllers/RestController.rb'
class HistoryController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Get all history objects for a given sensor
    def index
	    check_authentication
	    requestor = get_user(:l)
	    user = get_user
	    check_ownership_requestor_user(requestor,user)
        sensor = get_sensor(:sensor)
        History.all({:sensor => sensor}).map do |x| 
		    clean_id(x.attributes)
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
	    sensor = get_sensor(:sensor)
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
