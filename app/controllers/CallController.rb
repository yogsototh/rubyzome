require 'rubyzome/controllers/ServiceRestController'
class CallController < Rubyzome::ServiceRestController
   require 'time'
   require 'app/controllers/include/Helpers.rb'
   include Helpers

   def services
	{	
		:index => [:call_device],
     		:show  => [:call_device]
	}
   end

    def call_device
	# Get params
        user            = @request[:user]
        device_number   = @request[:number]

	puts %Q(Calling device #{device_number} owned by user #{user})

        # Call tropo call script (may use httparty gem)
	# TODO

    end
end
