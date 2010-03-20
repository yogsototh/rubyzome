require 'rubyzome/controllers/RestController.rb'
class UserController < RestController

    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Not available
    def index
	action_not_available
    end

    # Not available
    def create
	action_not_available
    end

    # Get user from user_id (nickname)
    # curl -i -XGET -d'l=login&p=password' http://gp.loc/users/luc.xml
    def show
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)

	clean_id(user.attributes)
    end

    # Update user 
    # curl -i -XPUT -d'l=login&p=password&nickname=nick' http://gp.loc/users/luc
    def update
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)

	begin
		user.update_attributes(clean_hash([:nickname]))
		user.save
	rescue
		raise GridError, "Cannot update user attributes"
	end

	clean_id(user.attributes)	
    end

    # Delete user from nickname => not authorized
    def delete
	action_not_available
    end
end
