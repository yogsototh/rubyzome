class Account
        # Includes
        include DataMapper::Resource

        # Propertiesi
        property :id,           Serial
        property :email,        String
        property :password,     String
        property :phone,        String

        # Associations
        belongs_to :user
end
