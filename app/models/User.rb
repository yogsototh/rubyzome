class User
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,                Serial
        property :nickname,        String
        property :status,        String

        # Associations
        has 1, :account,        :model => "Account"
        has 1, :twitterAccount,        :model => "TwitterAccount"
        has 1, :facebookAccount,       :model => "FacebookAccount"
end

