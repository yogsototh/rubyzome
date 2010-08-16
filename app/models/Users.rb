class User
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,           Serial
        property :nickname,     String
        property :phone,        String

        # Associations
        has 1, :account,        :model => "Account"
end

