require 'rubyzome/controllers/RestController.rb'
class MeasureController < Rubyzome::RestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

        # Get all measure for a given sensor
        # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures
        def index
                check_authentication
                sensor = get_sensor

                Measure.all({:sensor => sensor}).map{ |x| 
                        clean_id(x.attributes.merge(x.sensor.attributes))
                }
        end

        # Create a new measure for a sensor
        # curl -i -XPOST -d'l=login&p=pass&consumption=3434' http://gpadm.loc/sensors/main_home/measures
        # curl -i -XPOST -d'l=login&p=pass&consumption=3434' http://gpadm.loc/measures
        def create
                check_authentication
                sensor = get_sensor

                begin
                        measure = Measure.new( clean_hash([:consumption])  )
                        measure.sensor = sensor
                        measure.save
                rescue Exception => e
                        raise Rubyzome::Error, "Cannot create new measure: #{e.message}"
                end

                clean_id(measure.attributes)
        end

        # Get measure from measure_hrid
        # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures/measure_hr
        # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/measures/measure_hr
        def show
                check_authentication
                sensor =  get_sensor
                measure =  get_measure
                check_ownership_sensor_measure(sensor,measure)

                clean_id(measure.attributes)
        end

        # Update measure from measure_hr
        # curl -i -XPUT -d'l=login&p=pass&consumption=cons' http://gpadm.loc/sensors/main_home/measures/measure_hr
        # curl -i -XPUT -d'l=login&p=password&consumption=cons' http://gpadm.loc/measures/measure_hr
        def update
                check_authentication
                sensor =  get_sensor
                measure =  get_measure
                check_ownership_sensor_measure(sensor,measure)

                begin
                        measure.consumption = hash[:consumption]
                        measure.save
                rescue
                        raise Rubyzome::Error, "Cannot update measure: #{e.message}"
                end

                clean_id(measure.attributes)
        end

 
        # Delete measure from measure_hrid 
        # curl -i -XDELETE -d'l=login&p=pass' http://gpadm.loc/measures/measure_hr
        # curl -i -XDELETE -d'l=login&p=pass' http://gpadm.loc/sensors/main_home/measures/measure_hr
        def delete
                check_authentication
                sensor =  get_sensor
                measure =  get_measure
                check_ownership_sensor_measure(sensor,measure)

                begin
                        measure.destroy
                rescue Exception => e
                        raise Rubyzome::Error, "Cannot delete measure: #{e.message}"
                end

                action_completed("Measure #{measure.measure_hr} deleted")
        end
end
