class Facebook
        # Includes
        include DataMapper::Resource

        # Properties
        property :access_token,		String

        # Associations
        belongs_to :user
end

