class Facebook
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,			Serial
        property :access_token,		String

        # Associations
        belongs_to :user
end

