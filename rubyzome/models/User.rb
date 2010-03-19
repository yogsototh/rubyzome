class RubyzomeUser
    # Includes
    include DataMapper::Resource

    # Properties
    property :id,       Serial
    property :nickname, String

    # Associations
    has 1, :account, :model => "Account"
end

