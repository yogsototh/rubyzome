class Tracker
    # Includes
    include DataMapper::Resource

    # Properties
    property :id,                Serial
    property :tracker_hr,        String
    property :phoneNumber,        String

    # Associations
    belongs_to  :user,      :model => "User"
    has n, :location,        :model => "Location"
end

