require 'rubyzome/controllers/ServiceRestController.rb'
require 'time'

class MobileController < Rubyzome::ServiceRestController
    require 'app/controllers/include/Helpers.rb'
    include Helpers

    def services
        {    
            :index => [:info],
            :show  => [:info]
        }
    end

    require 'app/controllers/include/MeasureHelpers.rb'
    include MeasureHelpers

    # Get all measure for a given sensor
    # curl -i -d'l=login&p=password' -XGET http://gpadm.loc/sensors/main_home/measures
    def info
        check_authentication
        requestor = get_user(:l)
        user = get_user
        check_ownership_requestor_user(requestor,user)
        sensor = get_sensor
        check_ownership_user_sensor(user,sensor)

        # Get filter params
        nickname    = @request[:l]
        from        = @request[:from]
        to          = @request[:to]
        interval    = @request[:interval]

        @version=2

        # Get status
        status = User.first({:nickname => nickname}).status;

        # return last measure if from not given
        if from.nil?
            return show_last_measure(sensor).merge({:status=>status})
        end

        # if only from is given return all values from 'from'
        @client_offset=DateTime.parse(from).offset
        if to.nil?
            return show_measure_from(sensor,from).merge({:status=>status})
        end

        # Get time for "from" and "to" strings
        from = Time.parse(from)
        to = Time.parse(to)

        # Make sure from date is older than to date
        if(from > to) then
            raise Rubyzome::Error, "\"from\" date must be older than \"to\" date"
        end

        # if from and to given but not interval
        if interval.nil? or interval.to_i <= 0
            return show_measure_from_to(sensor,from,to).merge({:status => status})
        end

        return show_measure_from_to_with_interval(sensor,from,to,interval).merge({:status => status})
    end
end
