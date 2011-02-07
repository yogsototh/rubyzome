# An history object can be seen as a
# table of measure with the following property
# each measure has a round date at interval (from midnight)
# For example, if interval is 3600 (every hour)
# date should all be of the form hh:00:00.000
# And the value of the measure should be the mean consumption
# value during h:00:00.000 to (exclusive) h+1:00:00.000
class History
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,        Serial
        property :name,      String
        property :interval,  Integer # interval in seconds

        # Associations
        belongs_to :sensor, :model => "Sensor"
        has n, :measure,   :model => "HMeasure"
end

