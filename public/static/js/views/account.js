var AccountView = function() {
    this.user = mainApplication.user;
    this.password = mainApplication.password;
    this.message = "not loaded yet";
    this.login_params = { l: this.user, p: this.password, v:2 };
    this.num = 0;
}

AccountView.prototype.show = function(){
    var self=this;
    $('#menu').load('/static/html/menu.html');
    $('#content').load("/static/html/user_account.html",
                            function(){ self.htmlLoaded(self);});
}

AccountView.prototype.htmlLoaded = function(self) {
    self.showUserAccount();
}

AccountView.prototype.showUserAccount = function() {
    var self=this;

    $('#nickname').html(self.user);
    $('#password').val(self.password);
    $('#message').html(self.message);
    $('#updateButton').click(function(){ self.update_resource(self)} );
}

AccountView.prototype.update_resource = function (self) {

    console.log('self.user = '+self.user);
    console.log('self.password = '+self.password);
    console.log('self.message = '+self.message);

    $.post(
	    '/accounts/'+self.user+'.json', 
	    {   l: self.user,
	        p: self.password,
	        nickname: self.user, 
	        password: $('#password').val(),
	        _method: 'PUT'
	    },
	    function() {
	        $("#info").prepend('<div id="updated'+num+'">'+self.user+' updated!</div>');
	        setTimeout(function(){$('#updated'+num).remove()},1500);
	        self.num++;
	    });
}
