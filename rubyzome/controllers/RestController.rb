# encoding: utf-8

class RestController
    # ajoute un attribut Request
    # contenant les détails des requêtes
    attr_accessor :request

    # default functions
    def previous_filter
    end

    def after_filter
    end

    def _index
        previous_filter
        index
        after_filter
    end
    def index
	    action_not_available
    end

    def _create
        previous_filter
        create
        after_filter
    end
    def create
	    action_not_available
    end

    def _show
        previous_filter
        show
        after_filter
    end
    def show
	    action_not_available
    end

    def _update
        previous_filter
        update
        after_filter
    end
    def update
	    action_not_available
    end

    def _delete
        previous_filter
        delete
        after_filter
    end
    def delete
	    action_not_available
    end

    def _options
        previous_filter
        delete
        after_filter
    end
    def options
	    action_not_available
    end

    # on initialise avec un objet requête
    def initialize(req)
        @request=req
    end

    def bad_request
        raise Error, "Bad request, please refer to options"
    end

    # TODO: rename it as pruned_request for example
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
        raise Error, "This action is not available"
    end

    # Action completed 
    def action_completed(message)
        {:message => message}
    end

    # Mandatory params check
    def check_mandatory_params(mandatory_params)
        mandatory_params.each do |param| 
            if @request["#{param}"].nil? then
                raise Error.new("Mandatory parameter [#{param}] must be provided") 
            end
        end
    end
end
