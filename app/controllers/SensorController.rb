require 'rubyzome/controllers/RestController.rb'
class SensorController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    # Get all sensors for a given user
    # curl -i -XGET -d'l=login&p=password' http://gp.loc/users/luc/sensors
    def index
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)

        Sensor.all({:user => user}).map do |x| 
		clean_id(x.attributes)
        end
    end

    # Create a new sensor - Not available
    def create
	action_not_available
    end

    # Get sensor from sensor_id
    # curl -i -d'l=login&p=password' -XGET http://gp.loc/users/luc/sensors/main_home
    # curl -i -d'l=login&p=password' -XGET http://gp.loc/sensors/main_home
    def show
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)

	clean_id(sensor.attributes)
    end

    # Update sensor from sensor_id - Not available
    def update
	action_not_available
    end

    # Delete sensor - Not available
    def delete
	action_not_available
    end
end
