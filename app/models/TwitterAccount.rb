class TwitterAccount
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,			Serial
        property :consumer_token,	String
        property :consumer_secret,	String
        property :access_token,		String
        property :access_secret,	String
	property :publish,		Boolean, :default => false

        # Associations
        belongs_to :user
end

