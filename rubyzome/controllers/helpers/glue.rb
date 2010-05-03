module ResourcesFromRequest
    # get ressource object from name
    #
    #  in general request are in the form:
    #   MainRessources with params [ 
    #                       login_param,
    #                       general_param, 
    #                       subresource_1_id,
    #                       subresource_2_id, 
    #                       ... ,
    #                       subresource_n_id ]
    #  Most of time the controller need to access the object
    #  associated to subresource_x_id
    #  to get it, we need the model associated to the subresource_x_id
    #  most of time it is the name of the subresource_x_id which provide
    #  the associated model name. 
    #  For example todolist_id is most of time
    #  used to match a Todolist object.
    #  Sometime there could be strange name to access
    #  get_resource("todolist")
    #  will return 
    #       resource  = Todolist.first({:id => request[:todolist_id]})
    #
    #  For example as Todolist as :uid as primary key, we should have
    #  reclaimed:
    #  get_resource({ resource_name=>"todolist",db_pkey => :uid })
    #
    #  and if we provided the user to send todoidentifier 
    #  instead of todolist_id in the HTTP request we should
    #  have done
    #  get_resource({ resource_name =>"todolist",:uid,:todoidentifier)
    #
    #  and if todolist wasn't for Todolist model but for Egg
    #  we should have written
    #  get_resource({:db_pkey => :uid,
    #               :req_id => :todoidentifier,
    #               :model_name => "Egg"})
    #
    #  PARAMETERS
    #    or a simple string (resource_name)
    #    or a hash containing following key (not all mandatory)
    #    :resource_name     mandatory if :req_id 
    #                               and :model_name not given)
    #    :req_id            the name of the HTTP parameter 
    #                       used to identify resource
    #    :model_name        the model class name 
    #    :db_pkey           the primary key of the model
    def get_resource(params)
        # A bit of introspection
        if params.is_a?(String)
         resource_name=params
        elsif params.is_a?(Hash)
            resource_name=params[:resource_name]
            db_pkey=params[:db_pkey]
            req_id=params[:req_id]
            model_name=params[:model_name]
        else
            raise Error, "get_resource should take a String or Hash parameter"
        end
        # set default database id associated with ressource if needed
        req_id=%{#{resource_name}_id}.intern if req_id == nil
        # set the model name from the ressource name if needed
        model_name=resource_name.capitalize if model_name == nil
        # set the db primary key if needed
        db_pkey=:id if db_pkey == nil

        # get the given (by parameter) identifier of the ressource
        ressource_id = @request[req_id]
        # if no parameter is given demand from it
        if(ressource_id.nil?) then
            raise Error, "I lack the parameter #{req_id}"
        end

        # get the object from DB using ressource id to identify it
        ressource = Kernel.const_get(model_name).first({db_pkey => ressource_id})

        # raise an error if no ressource is found
        if(ressource.nil?) then
            raise Error, "Todolist #{ressource_id} does not exist"
        end
        return ressource
    end
end
