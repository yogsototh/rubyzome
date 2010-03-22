# encoding: utf-8

module Rubyzome
    require 'rubyzome/controllers/RestController.rb'
    class ServiceRestController < RestController

        def service_name
            @request[ (self.class.to_s.gsub(/Controller/,'').downcase + '_id' ).intern ].intern
        end

        def show
            if services[:show].include?(service_name)
                self.send(service_name)
            else
                raise  GridError, "Service #{service_name} not available"
            end
        end

        def update
            if ( services[:update].include?(service_name) )
                self.send(service_name)
            else
                raise  GridError, "Service #{service_name} not available"
            end
        end

        def index
            if services.empty?
                raise  GridError, "No service available"
            end
            services[:index].map { |service|
                self.send(service)
            }
        end

        # example
        # return { :index => [:completed] ,
        #           :put    => [:complete] }
        def services
            return {}
        end

    end
end
