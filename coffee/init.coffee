class window.Application
    user: ""
    password: ""
    remember: false

    log: (msg) ->
        console.log(msg) if console? and console.log?

    save: (info,value) ->
        this.log "save('#{info}','#{value}')"
        $.cookie(info,value,{expires: 14})

    forget: (info) ->
        this.log 'forget("'+info+'")' 
        $.cookie(info,null)

    setRemember: (remember) -> 
        if remember
            this.save 'user',this.user
            this.save 'password',this.password
            this.save 'remember',true
        else
            this.forget 'user'
            this.forget 'password'
            this.forget 'remember'

    setUser: (user) -> 
        this.user = user
        if this.remember
            this.save 'user',this.user

    setPassword: (password) ->
        this.password = password
        if this.remember
            this.save 'password',this.password

    retrieveSavedPreferences: ->
        self=this
        self.remember = $.cookie('remember')
        self.user = $.cookie('user')
        if self.user
            self.password = $.cookie('password')
            return true
        return false

    logout: ->
        $.cookie('user',null)
        $.cookie('password',null)
        $.cookie('remember',null)
        $.cookie('lastSelectedView',null)
        return true; # in order not to disable the link

    # execute the function action after all files are loaded only if needed
    #
    # example of usage:
    #
    # files=[]; 
    # tests=[]
    #
    # files.push('/static/js/date.js')
    # tests.push('Date.prototype.setISO8601')
    #
    # files.push('/static/js/flot/jquery.flot.js')
    # tests.push('$.flot')
    #
    # mainApplication.run_after_dependencies( files, tests, 
    #         function() {
    #            $('#content').load("/static/html/user_stats.html",
    #                function(){ self.htmlLoaded(self);})
    #            })
    #
    #
    run_after_dependencies: ( files, tests, action ) ->
        self=this
        if files.length==0
            action()
        else
            file=files.pop()
            test=tests.pop()
            eval('o='+test+';')
            if ( typeof o == "undefined")
                $.getScript file, 
                            ->
                              self.run_after_dependencies(files, tests, action)
            else
                self.run_after_dependencies(files, tests, action)

    connectionSuccessful: (self, success, failed ) -> 
        $.ajax( url: 
                    '/users/'+self.user+'.json'
                data: 
                     l: self.user
                     p: self.password
                success: 
                    success
                error: 
                    failed
                )

    run: ->
        self=this
        if self.retrieveSavedPreferences()
            self.connectionSuccessful(
                self,
                -> 
                    switch $.cookie('lastSelectedView')
                        when 'stats' then self.showUserStats()
                        when 'account' then self.showUserAccount()
                        else self.showUserConsumption()
                ,
                -> 
                    self.showLoginView() 
                )
        else
            self.showLoginView()
        $('#blackpage').fadeOut()

    showUserConsumption: ->
        $.cookie('lastSelectedView','consumption',{expires: 14})
        this.showView('consumption')

    showUserStats: ->
        $.cookie('lastSelectedView','stats',{expires: 14})
        this.showView('stats')

    showUserAccount: ->
        $.cookie('lastSelectedView','account',{expires: 14})
        this.showView('account')

    showLoginView: ->
        this.showView("login")

    # Add capitalize function to String objects
    String.prototype.capitalize = ->
        return this.charAt(0).toUpperCase() + this.slice(1)

    # This function enable a nice shortcut to show a view
    # self.showView('login')
    # will load the /static/js/view/login.js file dynamically (if needed)
    # then create an instance of LoginView class named loginView
    # and finally launch the loginView.show() method
    showView: (viewName) ->
        self=this
        viewObjectName=viewName+"View"
        viewClassName="window."+viewName.capitalize()+"View"
        viewFileName=viewName+".js"
        eval( "if ( typeof(self.#{viewObjectName}) == \"undefined\" ) {
                $.getScript('/static/js/views/#{viewFileName}',function(){
                    self.#{viewObjectName} = new #{viewClassName}(mainApplication);
                    self.#{viewObjectName}.show();
                });
            } else {
                self.#{viewObjectName}.show();
            }" )

mainApplication = new window.Application

# after document loaded
$(document).ready( -> 
    mainApplication.run() 
)
