# encoding: utf-8

class MeasureController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers


    # Get all measure for a given sensor
    # curl -i -d'l=login&p=password' -XGET http://gp.loc/sensors/main_home/measures
    def index
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)

        Measure.all( { :sensor => sensor } ).map do |x| 
                clean_id(x.attributes.merge(x.sensor.attributes))
        end
    end

    # Create a new measure for a sensor - Not available (admin action)
    def create
	action_not_available
    end

    # Get measure from measure_hrid
    # curl -i -d'l=login&p=password' -XGET http://gp.loc/sensors/main_home/measures/measure_hr
    # curl -i -d'l=login&p=password' -XGET http://gp.loc/measures/measure_hr
    def show
	check_authentication
	requestor = get_user(:l)
	user = get_user
	check_ownership_requestor_user(requestor,user)
	sensor = get_sensor
	check_ownership_user_sensor(user,sensor)
	measure = get_measure
	check_ownership_sensor_measure(sensor,measure)

	clean_id(measure.attributes)
    end

    # Update measure from measure_hrid - Not available (admin action)
    def update
	action_not_available
    end


    # Delete measure from measure_hrid - Not available (admin action)
    def delete
	action_not_available
    end
end
