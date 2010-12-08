class Location
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,           Serial
        property :date,                DateTime
        property :longitude,  String
        property :latitude,  String
        property :altitude,  String

        # Associations
        belongs_to :tracker,     :model => "Tracker"
end

