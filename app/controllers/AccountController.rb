require 'rubyzome/controllers/RestController.rb'
class AccountController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # curl -i -XGET http://gpadm.loc/accounts
    def index
        check_authentication

        Account.all.map{ |x| 
            clean_id(x.attributes.merge(x.user.attributes))
        }
    end

    # curl -i -XPOST -d'l=login&p=pass&...' http://gpadm.loc/accounts
    def create
        check_authentication
        check_mandatory_params([:email,
                               :password, 
                               :firstname, 
                               :lastname, 
                               :country, 
                               :zip, 
                               :city, 
                               :street])

        # User creation
        begin        
            user=User.new(clean_hash([:nickname]))
            user.save
        rescue Exception => e
            raise Rubyzome::Error, "Unable to create user: #{e.message}"
        end

        # Account creation
        begin
            hash=clean_hash( [        :email,
                            :password,
                            :firstname,
                            :lastname,
                            :country,
                            :zip,
                            :city,
                            :street] )
            hash[:user]=user
            account=Account.new(hash)
            account.save
            clean_id(account.attributes.merge(account.user.attributes))
        rescue Exception => e
            user.destroy!
            raise Rubyzome::Error, "Cannot create account: #{e.message}"
        end
    end

    # curl -i -XGET -d'l=login&p=pass' http://gpadm.loc/accounts/yogsototh
    def show
        check_authentication
        account = get_account

        clean_id(account.attributes.merge(account.user.attributes))
    end

    # curl -i -XPUT -d'l=login&p=pass&...' http://gpadm.loc/accounts/yogsototh
    def update
        check_authentication
        account = get_account

        begin
            clean_hash( [:email, :password, :firstname,
                       :lastname, :country, :zip,
                       :city, :street]).each do |key,val|
                account.update( { key => val })
            end
            account.user.update({:status => @request[:status]}) if not @request[:status].nil?
            account.user.save
            account.save
        rescue Exception => e
            raise Rubyzome::Error, "Cannot update account: #{e.message}"
        end

        clean_id(account.attributes)
    end

    # curl -i -XDELETE -d'l=login&p=pass' http://gpadm.loc/accounts/yogsototh
    def delete
        check_authentication
        account = get_account
        user = account.user

        begin
            account.destroy!
        rescue Exception => e
            raise Rubyzome::Error, "Cannot delete account linked to user #{user.nickname}: #{e.message}"
        end

        begin
            user.destroy!
        rescue Exception => e
            raise Rubyzome::Error, "Cannot delete user #{user.nickname}: #{e.message}"
        end

        action_completed("User #{user.nickname} and associated account deleted")
    end
end