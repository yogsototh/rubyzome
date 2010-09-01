module Helpers

    ### AUTHENTICATION ###

    def check_authentication
        user=User.first({:nickname => @request[:l]})
        if user.nil?
            raise Rubyzome::Error, "Authentication failed, user with login #{@request[:l]} does not exist"
        end
        if(@request[:p] != Account.first({:user => user}).password) then
            raise Rubyzome::Error, "Authentication failed, please check username and password"
        end
    end

    ### ACCOUNT STUFF ###

    def get_account(id=:account_id)
        account_id = @request[id]
        if(account_id.nil?) then
            raise Rubyzome::Error, "No user provided"
        end
        user = User.first({:nickname => account_id})
        if(user.nil?) then
            raise Rubyzome::Error, "User #{account_id} does not exist"
        end
        account = user.account
        if(account.nil?) then
            raise Rubyzome::Error, "No account linked to user #{user_id}"
        end
        return account
    end

    ### USER STUFF ###

    def get_user(id=:user_id)
        user_id = @request[id]
        if(user_id.nil?) then
            raise Rubyzome::Error, "No user provided"
        end
        user = User.first({:nickname => user_id})
        if(user.nil?) then
            raise Rubyzome::Error, "User #{user_id} does not exist"
        end
        return user
    end

    ### TRACKER STUFF ###

    def get_tracker(id=:tracker_id)
        tracker_id = @request[id]
        if(tracker_id.nil?) then
            raise Rubyzome::Error, "No tracker provided"
        end
        tracker = Tracker.first({:tracker_hr => tracker_id})
        if(tracker.nil?) then
            raise Rubyzome::Error,"Tracker #{tracker_id} does not exist"
        end
        return sensor
    end

    ### OWNERSHIP ###

    def check_ownership_user_account(user,account)
        if account.user != user
            raise Rubyzome::Error, "Account is not linked to user #{user.nickname}"
        end
    end

    def check_ownership_user_tracker(user,tracker)
        if tracker.user != user then
            raise Rubyzome::Error, "Tracker #{tracker.tracker_hr} does not belong to User #{user.nickname}"
        end
    end

    ### ONLY USED IN USER PART ###

    def check_ownership_requestor_user(requestor,user)
        if requestor.nickname != user.nickname
            raise Rubyzome::Error, "Requestor #{requestor.nickname} and user requested #{user.nickname} do not match"
        end
    end


    ### UTIL ###

    def clean_id(hash)
        hash.delete(:id)
        hash.delete(:user_id)
        hash.delete(:account_id)
        hash.delete(:tracker_id)
        hash
    end
end
