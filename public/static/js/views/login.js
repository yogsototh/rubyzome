var LoginView = function() {
    this.self=this;
}

LoginView.prototype.show = function() {
    var self=this;
    $('#content').load("/static/html/login.html",self.htmlLoaded);
}

LoginView.prototype.submitForm = function() {
    mainApplication.setUser( $('[name=l]').val());
    mainApplication.setPassword( $('[name=p]').val());
    if ($('#remember').attr('checked')) {
        $.cookie('user',mainApplication.user,{expires: 14});
        $.cookie('password',mainApplication.password,{expires: 14});
        $.cookie('remember',true,{expires: 14});
    } else {
        $.cookie('user',null);
        $.cookie('password',null);
        $.cookie('remember',true,null);
    }
    mainApplication.showUserConsumption();
    return false;
}

LoginView.prototype.test = function () {
    alert('Prototype test');
}

LoginView.prototype.htmlLoaded = function() {
    var self=this;
    console.log('htmlLoaded [typeof this='+typeof(this)+']');
    console.log('[typeof this.test='+typeof(this.test)+']');
    // self.autoclear('username','User Name');
    // self.autoclear('password','');
    /*
    $("#username").click(
            function() { 
                this.value=''; 
                this.select(); 
                $(this).removeClass('inactive'); });
    $("#username").focus(function() { 
            this.value=''; 
            this.select(); 
            $(this).removeClass('inactive'); });
    $("#username").blur(
            function(){ if ( this.value == '' ) {
                this.value='User Name'; $(this).addClass('inactive');}
            });

    $("#password").click(self.autoclear);
    $("#password").focus(self.autoclear);
    */
    $('form[name=login_form]').submit(function(){self.submitForm()});
}


