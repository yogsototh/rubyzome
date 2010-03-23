class Measure
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,           Serial
        property :measure_hr,        String
        property :date,                DateTime
        property :consumption,  Integer

        # Associations
        belongs_to :sensor,     :model => "Sensor"

end

