class window.LoginView
    constructor: (@app) ->

    show: ->
        self=this
        $('#titles h1').html('Sign in')
        $('#content').load( "/static/html/login.html", 
                           -> self.htmlLoaded(self))

    handleCookie: ->
        if $('#remember').attr('checked')
            @app.setRemember(true)
        else
            @app.setRemember(false)

    formSubmitted: ->
        self=this; # necessary because use ajax sub-function
        self.app.setUser( $('[name=l]').val());
        self.app.setPassword( $('[name=p]').val());
        self.handleCookie();
        $.ajax( {
                url: '/users/'+self.app.user+'.json',
                data: 
                    "l": self.app.user
                    "p": self.app.password
                ,
                success: -> self.app.showUserConsumption() ,
                error: ->
                    $("#info").prepend('<div id="error">Authentication failed</div>')
                    setTimeout( ( -> $('#error').remove() ) ,2000);
                });
        return false;

    htmlLoaded: (self) ->
        self.autoclear('username','User Name');
        self.autoclear('password','');
        $('form[name=login_form]').submit( -> self.formSubmitted() )

    clear: () ->
        this.value='';
        this.select();
        $(this).removeClass('inactive');

    inputDefaultValue: (o,defaultValue) ->
        self=this
        self.app.log('inputDefaultValue: '+defaultValue);
        if (o.value == '')
            o.value=defaultValue; 
            $(o).addClass('inactive')
    autoclear: (id,defaultValue) ->
        # this -> input 
        # self -> class
        self=this;
        $('#'+id).click( self.clear )
        $('#'+id).focus( self.clear )
        $('#'+id).blur( -> self.inputDefaultValue(this,defaultValue) );
