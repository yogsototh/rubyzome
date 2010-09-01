class Account
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,                Serial
        property :email,        String
        property :password,        String
        property :firstname,        String
        property :lastname,        String

        # Associations
        belongs_to :user
end

