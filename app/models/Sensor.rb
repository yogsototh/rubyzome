class Sensor
    # Includes
    include DataMapper::Resource

    # Properties
    property :id,               Serial
    property :sensor_hr,        String
    property :description,      String
    property :address,          String
    property :last_cleaned,     DateTime

    # Associations
    belongs_to  :user,      :model => "User"
    has n, :measure,        :model => "Measure"
end

