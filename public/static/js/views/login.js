var LoginView = function() {
    this.self=this;
}

LoginView.prototype.show = function() {
    var self=this;
    $('#content').load("/static/html/login.html",
                       function() { self.htmlLoaded(self) });
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

LoginView.prototype.clear = function() {
    this.value='';
    this.select();
    $(this).removeClass('inactive');
}
LoginView.prototype.inputDefaultValue = function(o,defaultValue) {
    console.log('inputDefaultValue: '+defaultValue);
    if (o.value == '') {
        o.value=defaultValue; 
        $(o).addClass('inactive')
    }
}

LoginView.prototype.autoclear = function(id,defaultValue) {
    var self=this;
    $('#'+id).click( self.clear );
    $('#'+id).focus( self.clear );
    // this designe l'input alors que self designe la classe dans la sous fonction
    $('#'+id).blur( function() { self.inputDefaultValue(this,defaultValue) } );
}

LoginView.prototype.htmlLoaded = function() {
    var self=this;
    self.autoclear('username','User Name');
    self.autoclear('password','');
    $('form[name=login_form]').submit(function(){self.submitForm()});
}


