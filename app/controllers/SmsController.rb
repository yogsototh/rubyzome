class SmsController < Rubyzome::ServiceRestController
   require 'time'
   require 'app/controllers/include/Helpers.rb'
   include Helpers

   def services
	{	
		:index => [:handle_incoming_sms],
     		:show  => [:handle_incoming_sms]
	}
   end

    # Method called on each new sms received
    def handle_incoming_sms
	# Get params
        from            = @request[:from]
        to              = @request[:to]
        message         = @request[:message]

	puts "About to handle SMS: from:#{from}, to:#{to}, message:#{message}"

	# Variables declaration
	latitude, longitude, date = nil, nil, nil

	# Extract latitude / longitude / date from message
	#
	# GPS 1: 
	# 
	# lat:43.619312
	# long:007.073966
	# speed:000.0
	# T:10/08/10 18:43
	# Bat:80%
	# http://www.wxlyx.com/GPSTracker.aspx?key=354777331664133@1857936.43@73966.21
	# 
	# GPS 2:
	# 
	# Latitude:43.671935N
	# Longitude:007.045995E
	# Speed(km/h):0.00
	# Direction:0.00
	# GMT:2010/08/22
	# 13:23:55
	# Battery:56%
	# 

	message.gsub(/(^[^:]*):(.*)$/).each do |i| 
        	if $1.eql?("lat") || $1.eql?("latitude") || $1.eql?("Latitude") then
			latitude = $2.to_f
		elsif $1.eql?("long") || $1.eql?("longitude") || $1.eql?("Longitude") then
			longitude = $2.to_f
		elsif $1.eql?("T") || $1.eql?("GMT") then
			# Check date format and create DateTime object
			# TODO
			date = $2
		end
	end

	puts %{lat:#{latitude} - long:#{longitude} - date:#{date}}

	# Get tracker which sent the current sms
	tracker = Tracker.first({:phoneNumber => from})

	if not tracker.nil? then
		# Create Location entry for the tracker retrieve
		location = Location.new({:latitude	=> latitude,
					 :longitude	=> longitude,
					 :altitude	=> 0,
					 :date		=> date,
					 :tracker	=> tracker})
		location.save	
	else
		puts "No tracker with phone number:#{from} found in DB..."
	end

	{:message => %Q{incoming sms handled}}
    end
end
