class FacebookAccount
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,			Serial
        property :access_token,		String
	property :publish,		Boolean, :default => false

        # Associations
        belongs_to :user
end

