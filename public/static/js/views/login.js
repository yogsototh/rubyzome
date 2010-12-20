var LoginView = function() {
    var self=this;
}

LoginView.prototype.become_active = function() { 
    $(this).removeClass('inactive'); 
}
LoginView.prototype.select_and_active = function select_and_active() {
    $(this).select();
    $(this).removeClass('inactive');
}
LoginView.prototype.clearInput = function () {
    this.value=''; 
    this.select(); 
    $(this).removeClass('inactive');
}

LoginView.prototype.setDefaultInput = function (elem, defaultValue) {
    if (!elem.value) {
        elem.value=defaultValue; 
        $(elem).addClass('inactive');
    }
}


LoginView.prototype.htmlLoaded = function() {
    $("#username").click(self.clearInput);
    $("#username").focus(self.clearInput);
    $("#username").blur( function() {self.setDefaultInput(this,"User Name");});
    $("#password").click(self.clearInput);
    $("#password").focus(self.clearInput);

    $('form[name=login_form]').submit(function (){
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
        self.application.showUserConsumption();
        return false;
    });
}

LoginView.prototype.show = function() {
    $('#content').load("/static/html/login.html",self.htmlLoaded);
}

