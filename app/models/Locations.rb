class Location
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,           Serial
        property :date,         DateTime
        property :lat,  	Integer
        property :long,  	Integer
        property :alt,  	Integer

        # Associations
        belongs_to :tracker,     :model => "Tracker"
end
