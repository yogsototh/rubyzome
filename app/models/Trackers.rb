class Tracker
	# Includes
	include DataMapper::Resource

	# Properties
	property :id,	        Serial
	property :phone,	String

	# Associations
	belongs_to :user
end

