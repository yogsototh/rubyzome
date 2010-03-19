class User
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,                Serial
        property :nickname,        String
        property :status,        String

        # Associations
        has 1, :account,        :model => "Account"
        # has n, :sensors,     :model => "Sensor"

end

