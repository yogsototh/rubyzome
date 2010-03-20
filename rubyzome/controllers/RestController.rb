class RestController

    # Use helpers module
    require "rubyzome/controllers/Helpers.rb"
    include Helpers

    # ajoute un attribut Request
    # contenant les détails des requêtes
    attr_accessor :request

    # on initialise avec un objet requête
    def initialize(req)
        @request=req
    end

    def bad_request
        raise GridError, "Bad request, please refer to options"
    end

    def clean_hash( tab )
        hash={}
        tab.each do |t| 
            if not @request[t].nil?
                hash[t]=@request[t]
            end
        end
        hash
    end

   # Action not available
   def action_not_available
        raise GridError, "This action is not available"
   end

   # Action completed 
   def action_completed(message)
        {:message => message}
   end

   # Mandatory params check
   def check_mandatory_params(mandatory_params)
        mandatory_params.each do |param| 
                if @request["#{param}"].nil? then
                        raise GridError.new("Mandatory parameter [#{param}] must be provided") 
                end
        end
   end
end
