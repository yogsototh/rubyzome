class AccountController < RestController

    # Not available (should be done through admin) 
    def index
	action_not_available
    end

    # Not available (should be done through admin) 
    def create
	action_not_available
    end

    # curl -i -XGET -d'l=login&p=pass' http://gp.loc/accounts/yogsototh
    def show
	check_authentication
	account = get_account
	user = get_user(:l)
	check_ownership_user_account(user,account)
	
        clean_id(account.attributes.merge(account.user.attributes))
    end

    # curl -i -XUPDATE -d'l=login&p=pass&...' http://gp.loc/accounts/yogsototh
    def update
	check_authentication
	account = get_account
	user = get_user(:l)
	check_ownership_user_account(user,account)

	begin
		account.update_attributes( clean_hash([	:email,
							:password,
							:firstname,
							:lastname,
							:country,
							:zip,
							:city,
							:street]) )
	rescue Exception => e
		raise GridError,"Cannot update account attributes: #{e.message}"
	end

	clean_id(account.attributes.merge(account.user.attributes))
    end

    # Not available (should be done through admin) 
    def delete
	action_not_available
    end
end
