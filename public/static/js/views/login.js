var LoginView = function() {}

LoginView.prototype.show = function() {
    var self=this;
    $('#content').load( "/static/html/login.html",
                    function() { self.htmlLoaded(self) });
}

LoginView.prototype.handleCookie = function() {
    // save cookie
    if ($('#remember').attr('checked')) {
        mainApplication.setRemember(true);
    } else {
        mainApplication.setRemember(false);
    }
}

// function called when form is submited
LoginView.prototype.submitForm = function() {
    var self=this;

    mainApplication.setUser( $('[name=l]').val());
    mainApplication.setPassword( $('[name=p]').val());

    self.handleCookie();

    $.ajax( {
            url: '/users/'+mainApplication.user+'.json',
            data: { "l": mainApplication.user, "p": mainApplication.password },
            success: function() { 
                mainApplication.showUserConsumption(); 
            },
            error: function(){
                $("#info").prepend('<div id="error">Authentication failed</div>');
                setTimeout(function(){$('#error').remove()},2000); 
            }});

    return false;
}

LoginView.prototype.htmlLoaded = function() {
    var self=this;
    self.autoclear('username','User Name');
    self.autoclear('password','');
    $('form[name=login_form]').submit( function() { return self.submitForm() });
}

//--  start: autoclear inputs  --
LoginView.prototype.clear = function() {
    this.value='';
    this.select();
    $(this).removeClass('inactive');
}
LoginView.prototype.inputDefaultValue = function(o,defaultValue) {
    mainApplication.log('inputDefaultValue: '+defaultValue);
    if (o.value == '') {
        o.value=defaultValue; 
        $(o).addClass('inactive')
    }
}

// usage with id
LoginView.prototype.autoclear = function(id,defaultValue) {
    var self=this;
    $('#'+id).click( self.clear );
    $('#'+id).focus( self.clear );
    // this designe l'input alors que self designe la classe dans la sous fonction
    $('#'+id).blur( function() { self.inputDefaultValue(this,defaultValue) } );
}
//-- end: autoclear inputs  --
