# encoding: utf-8

# The code in this file is part of the Rubyzome framework
# Rubyzome framework belongs to Luc Juggery and Yann Esposito

module Rubyzome

    # The RestfulDispatcher class handle the automatic routing of the
    # application using filename and classname.
    class RestfulDispatcher
        @view = nil

        # Select the view to be used to render the object
        def selectView(model,path)

            # If it is a file of a website which is required then use the file load
            if path.empty? or path =~ /^#{$directory_of_website}\//
                puts "nil view returned, path : #{path}"
                @view=nil
                return
            end

            # View used is based upon request's last characters
            # .html => HTMLView
            # .json => JSONView
            # .xml  => XMLView
            type = File.extname(path)
            if type.empty?
                type = 'html'
            else
                type.slice!(0)
            end

            view_name=%{/#{type.downcase}/}
            # if request on a specific ressource
            if path.split('/').length % 2 != 0
                # check Single Ressource Type Specific View
                # eg: /stats/history.xml will render using
                #           /app/views/xml/HistoryStatXMLView
                specific_object=File.basename(path, ".#{type}").capitalize
                view_name<<=%{#{specific_object}#{model}#{type.upcase}View}
                    puts %{try view = #{view_name}} 
                    if $views.has_key?(view_name)
                        @view=$views[view_name].new
                        puts %{selected view = #{view_name}} 
                        return
                    end
                # check Ressource Type Specific View
                # eg: /stats.xml will render using
                #           app/views/xml/StatXMLView
                view_name=%{/#{type.downcase}/#{model}#{type.upcase}View}
                    puts %{try view = #{view_name}} 
                    if $views.has_key?(view_name)
                        @view=$views[view_name].new
                        puts %{selected view = #{view_name}} 
                        return
                    end
            else
                # check Plural Ressource Specific View
                # eg: /stats.xml will render using
                #           app/views/xml/StatsXMLView
                view_name<<=%{#{model}s#{type.upcase}View}
                    puts %{try view = #{view_name}} 
                    if $views.has_key?(view_name)
                        @view=$views[view_name].new
                        puts %{selected view = #{view_name}} 
                        return
                    end
            end

            # Check Type Generic View 
            # eg: /users.xml will render using 
            #           app/view/XMLView
            view_name = %{#{type.upcase}View}
                puts %{try view = #{view_name}} 
                if $views.has_key?(view_name)
                    @view=$views[view_name].new
                    puts %{selected view = #{view_name}} 
                    return
                end

                puts %{no view selected} 
                # No view found...
                @view=nil
        end

        # Nice html error (404 by default)
        def html_error(e, controller_name=nil, function_name=nil) 
            view=$view['HTMLView'].new
            [   404, 
                $views['HTMLView'].head, 
                $views['HTMLView'].new.httpContent( { :error => 404, :exception => e })
            ]
        end

        def internal_error(e, hash=nil)
            if e.is_a?(Error) and not e.code.nil?
                code=e.code
            else
                code=500
            end
            if hash.nil?
                hash={:error => code, :exception => e}
            else
                hash=hash.merge({:error => code, :exception => e})
            end
            [ code, @view.head, @view.httpContent(hash) ]
        end

        def general_error(e, hash=nil)
            if hash.nil?
                hash={:error => 500, :exception => e}
            else
                hash=hash.merge({:error => 500, :exception => e})
            end
            [ 500, @view.head, @view.httpContent({:error => 500, :exception => e}) ]
        end

        # Fonction triggered for each HTTP request 
        def call(env)
            # Request holds all HTTP parameters
            request = Rack::Request.new(env)

            # dispatcher returns: 
            #   name of the model, 
            #   name of the model's controller and 
            #   name of the controller's function to call
            model_name, controller_name, function_name = dispatcher_class(request)

            # Set the view to be used
            selectView(model_name,request.path)

            # Call right method on right controller
            # (if request is HTTP GET, body is the result of the 'get' method of the controller)
            # If no view selected, try to load the file associated to the path
            if @view.nil?
                begin
                    puts request.path.sub($directory_of_website,'/public')
                    # third choice, prefer loading file
                    file=File.new(request.path.sub($directory_of_website,'public'),'r')
                    # load the content of the file in memory 
                    # may be not the best way to do that
                    # TODO: caching issue for file who didn't changed
                    #       may be pushing all file content into memory
                    #       for faster usage is the first naive method
                    content = file.collect
                    file.close
                    # MIME Type get
                    # head={ 'Content-Type' => MIME::Types.of('file')[0].to_s }
                    head={ 'Content-Type' => 'text/html' }
                    puts head.to_s
                    return [200, head, content ] 
                rescue Exception => e
                    return html_error(e)
                end
            else
                # Controller creation and init with current request
                # Call requested function
                begin
                    body = Kernel.const_get(controller_name).new(request).send function_name
                rescue Error => e
                    return internal_error(e, {:controller_name => controller_name, :function_name => function_name } )
                rescue Exception => e
                    return general_error(e, {:controller_name => controller_name, :function_name => function_name } ) 
                end

                # had the request object to the view if possible
                if @view.respond_to?(:request)
                    @view.request=request
                end

                return [200, @view.head, @view.httpContent(body) ]
            end
        end

        # renvoie une nouvelle instance de sa propre classe
        # avec l'objet request mis correctement
        # /users/nickname/events/32?user='my_nickname'&password='PaSsW0rc|'
        # -> EventController
        # avec en paramètres GET+POST params
        #  + event_id='32'
        #  + user_id='nickname'
        def dispatcher_class(request)
            path=request.path

            # Remove path extension (.json or .xml for example)
            type=File.extname(path)
            path.chomp!(type)
            type.slice!(0)

            classname=''
            modelname = ''
            last_class_id=''
            function_name=''
            i=0
            path.split('/').each do |chemin|
                if chemin == ''
                    next
                end
                if i%2==0
                    classname = chemin[0..-2].capitalize + 'Controller'
                    modelname = chemin[0..-2].capitalize
                    last_class_id=chemin[0..-2]+'_id'
                    if request[:_method].nil?
                        if request.get?
                            function_name=:index
                        elsif request.post?
                            function_name=:create
                        elsif request.request_method == 'OPTIONS'
                            function_name=:options
                        else
                            function_name=:bad_request
                        end
                    else
                        case request[:_method]
                        when "GET"      then function_name=:index
                        when "POST"     then function_name=:create
                        when 'OPTIONS'  then function_name=:options
                        else                 function_name=:bad_request
                        end
                    end
                else
                    # on ajoute la valeur dans les paramètre
                    # en fonction du chemin
                    # /objects/toto --> request[objects_id]='toto'
                    request[last_class_id]=chemin
                    # dispatche la fonction a appeler en fonction
                    # du type de requête.
                    if request[:_method].nil?
                        if request.get?
                            function_name=:show
                        elsif request.put?
                            function_name=:update
                        elsif request.delete?
                            function_name=:delete
                        elsif request.request_method == 'OPTIONS'
                            function_name=:options
                        else
                            function_name=:bad_request
                        end
                    else
                        case request[:_method]
                        when 'GET'  
                            function_name=:show
                        when 'PUT'  
                            function_name=:update
                        when 'DELETE'   
                            function_name=:delete
                        when 'OPTIONS'  
                            function_name=:options
                        else            
                            function_name=:bad_request
                        end
                    end
                end
                i+=1
            end
            return modelname, classname, function_name
        end
    end

end
