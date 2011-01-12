require 'rubyzome/controllers/RestController.rb'
class UserController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Get all users 
    # curl -i -XGET -d'l=login&p=password' http://gpadm.loc/users.xml
    def index
        check_authentication

        User.all.map {|x| clean_id(x.attributes)}
    end

    # Create a new user - Not available
    def create
        action_not_available
    end

    # Get user from user_id (nickname)
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/users/luc.xml
    def show
        check_authentication
        user = get_user

        clean_id(user.attributes)
    end

    # Update user 
    # curl -i -XPUT -d'l=login&p=password&nickname=nick' http://gpadm.loc/users/luc
    def update
        check_authentication
        user = get_user
	current_status = user.status

        begin
	    # Get params
            params = clean_hash([:nickname,:status])
	    nickname = params[:nickname]
	    new_status = params[:status]

	    # Update user
	    user.update( {:nickname => nickname, :status => new_status} )
            user.save

	    # Update status if changed
	    if !new_status.eql?(current_status) then
			# Update Twitter account 
			update_twitter(nickname, new_status)

			# Update Facebook account
			update_facebook(nickname, new_status)
	    end

        rescue Exception => e
            raise Rubyzome::Error,"Cannot update user: #{e.message}"        
        end

        clean_id(user.attributes)
    end

    # Delete user from nickname
    # curl -i -XDELETE -d'l=login&p=password' http://gpadm.loc/users/toto
    def delete
        check_authentication
        user = get_user
        account = Account.first({:user => user})

        begin
            account.destroy!
        rescue Exception => e
            raise GridException, "Cannot delete account linked to user #{user.nickname}"
        end

        begin
            user.destroy!
        rescue Exception => e
            raise GridException, "Cannot delete user #{user.nickname}: #{e.message}"
        end

        action_completed("User #{user.nickname} and associated account has been deleted")
    end
end
