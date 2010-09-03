require 'rubyzome/controllers/RestController.rb'
require 'time'
class LocationController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    def encapsulate(locations, interval = 0)
        {
            'from'		=> locations[0].date,
            'to'		=> locations[-1].date,
            'data'		=> locations.map{ |x| x.consumption },
        }
    end

        # Get locations for a given tracker
        def index
	    check_authentication
       	    requestor = get_user(:l)
	    user = get_user
    	    check_ownership_requestor_user(requestor,user)
	    tracker = get_tracker
	    check_ownership_user_tracker(user,tracker)

            # return all locations in first test
            return encapsulate(Measure.all)
	end

	# Create a new location for a tracker -- Not available (admin action)
	def create
		action_not_available
	end

	# Get location at a particuliar date
	def show
		check_authentication
		requestor = get_user(:l)
		user = get_user
		check_ownership_requestor_user(requestor,user)
		tracker = get_tracker
		check_ownership_user_sensor(user,tracker)
		location = get_location
		check_ownership_tracker_location(tracker,location)

		clean_id(location.attributes)
	end

	# Update measure from measure_hrid - Not available (admin action)
	def update
		action_not_available
	end

	# Delete measure from measure_hrid - Not available (admin action)
	def delete
		action_not_available
	end
end
