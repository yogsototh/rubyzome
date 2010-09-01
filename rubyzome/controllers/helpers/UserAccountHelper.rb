module Rubyzome
    module AccountUserHelper

        ### AUTHENTICATION ###

        def check_authentication
            user=User.first({:nickname => @request[:l]})
            if user.nil?
                raise Error, "Authentication failed, user with login #{@request[:l]} does not exist"
            end
            if(@request[:p] != Account.first({:user => user}).password) then
                raise Error, "Authentication failed, please check username and password"
            end
        end

        ### ACCOUNT STUFF ###

        def get_account(id=:account_id)
            account_id = @request[id]
            if(account_id.nil?) then
                raise Error, "No user provided"
            end
            user = User.first({:nickname => account_id})
            if(user.nil?) then
                raise Error, "User #{account_id} does not exist"
            end
            account = user.account
            if(account.nil?) then
                raise Error, "No account linked to user #{user_id}"
            end
            return account
        end

        ### USER STUFF ###

        def get_user(id=:user_id)
            user_id = @request[id]
            if(user_id.nil?) then
                raise Error, "No user provided"
            end
            user = User.first({:nickname => user_id})
            if(user.nil?) then
                raise Error, "User #{user_id} does not exist"
            end
            return user
        end

        ### OWNERSHIP ###

        def check_ownership_user_account(user,account)
            if account.user != user
                raise Error, "Account is not linked to user #{user.nickname}"
            end
        end

        def check_ownership_requestor_user(requestor,user)
            if requestor.nickname != user.nickname
                raise Error, "Requestor #{requestor.nickname} and user requested #{user.nickname} do not match"
            end
        end


        ### UTIL ###

        def clean_id(hash)
            hash.delete(:id)
            hash.delete(:user_id)
            hash.delete(:account_id)
            hash
        end
    end
end
