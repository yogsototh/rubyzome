class Twitter
        # Includes
        include DataMapper::Resource

        # Properties
        property :consumer_token,	String
        property :consumer_secret,	String
        property :access_token,		String
        property :access_secret		String

        # Associations
        belongs_to :user
end

