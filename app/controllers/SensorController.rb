require 'rubyzome/controllers/RestController.rb'
class SensorController < RestController

        # Get all sensors for a given user or for all users
        # curl -i -XGET -d'l=login&p=password' http://gpadm.loc/users/luc/sensors
        # curl -i -XGET -d'l=login&p=password' http://gpadm.loc/sensors
        def index
                check_authentication

                if(@request[:user_id]) then
                        user = get_user
                        Sensor.all({:user => user}).map {|x| 
                                clean_id(x.attributes)
                        }
                else
                        Sensor.all.map {|x| 
                                clean_id(x.attributes)
                        }
                end
        end

        # Create a new sensor
        # curl -i -XPOST -d'l=login&p=password&sensor_hr=hr&description=description&address=address' http://gpadm.loc/sensors
        def create
                check_authentication
                user = get_user
                check_mandatory_params([:sensor_hr,
                                        :description,
                                        :address])

                begin
                        sensor = Sensor.new( clean_hash([:sensor_hr,:description,:address]) )
                        sensor.user = user
                        sensor.save
                rescue Exception => e
                        raise GridError, "Cannot create sensor: #{e.message}"
                end

                clean_id(sensor.attributes)
        end

        # Get sensor from sensor_id
        # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/users/luc/sensors/main_home
        # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home
        def show
                check_authentication
                user = get_user
                sensor = get_sensor
                check_ownership_user_sensor(user,sensor)

                clean_id(sensor.attributes)
        end

        # Update sensor from sensor_id 
        # curl -i -XPUT -d'l=login&p=pass&...' http://gpadm.loc/sensors/main_home
        def update
                check_authentication
                user = get_user
                sensor = get_sensor
                check_ownership_user_sensor(user,sensor)

                begin
                        sensor.sensor_hr         = hash[:sensor_hr]        if not hash[:sensor_hr].nil?
                        sensor.description         = hash[:description]         if not hash[:description].nil?
                        sensor.address                 = hash[:address]         if not hash[:address].nil?
                        sensor.save
                rescue Exception => e
                        raise GridError, "Cannot update sensor: #{e.message}"
                end 

                clean_id(sensor.attributes)
        end

        # Delete sensor from sensor id 
        # curl -i -XDELETE -d'l=login&p=password' http://gpadm.loc/sensors/main_home
        # curl -i -XDELETE -d'l=login&p=password' http://gpadm.loc/users/luc/sensors/main_home
        def delete
                check_authentication
                user = get_user
                sensor = get_sensor
                check_ownership_user_sensor(user,sensor)

                begin
                        sensor.destroy
                rescue Exception => e
                        raise GridError, "Cannot delete sensor: #{e.message}"        
                end

                action_completed("Sensor #{sensor.sensor_hr} deleted")
        end
end
