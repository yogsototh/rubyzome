class Location
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,           Serial
        property :date,                DateTime
        property :longitude,  Float
        property :latitude,  Float
        property :altitude,  Float

        # Associations
        belongs_to :tracker,     :model => "Tracker"
end

