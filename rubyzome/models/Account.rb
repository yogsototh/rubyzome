class RubyzomeAccount
    # Includes
    include DataMapper::Resource

    # Properties
    property :id,       Serial
    property :password, String

    # Associations
    belongs_to :user
end

