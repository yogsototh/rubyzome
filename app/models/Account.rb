class Account
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,                Serial
        property :email,        String
        property :password,        String
        property :firstname,        String
        property :lastname,        String
        property :country,        String
        property :zip,                String
        property :city,                String
        property :street,        String

        # Associations
        belongs_to :user
end

