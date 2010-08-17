require 'rubyzome/controllers/RestController.rb'
class UserController < Rubyzome::RestController
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
        ["it works"]
    end

    # Update user 
    # curl -i -XPUT -d'l=login&p=password&nickname=nick' http://gp.loc/users/luc
    def update
        action_not_available
    end

    # Delete user from nickname => not authorized
    def delete
        action_not_available
    end
end
