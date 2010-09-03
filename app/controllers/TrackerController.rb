require 'rubyzome/controllers/RestController.rb'
class TrackerController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Get all tracker for a given user
    def index
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)

        # Tracker.all.map do |x| 
        Tracker.all({:user => user}).map do |x| 
		clean_id(x.attributes)
        end
    end

    # Create a new tracker - Not available
    def create
	action_not_available
    end

    # Get tracker from tracker_id
    def show
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	tracker = get_tracker
	check_ownership_user_tracker(user,tracker)

	clean_id(tracker.attributes)
    end

    # Update tracker from tracker_id - Not available
    def update
	action_not_available
    end

    # Delete tracker - Not available
    def delete
	action_not_available
    end
end
