var MainApplication = function () {
    self=this;
    this.user="";
    this.password="";

    this.setUser = function(user) { this.user = user; }
    this.setPassword = function(password) { this.password = password; }

    this.getUserFromCookie = function() {
        self.user = $.cookie('user');
        if (self.user) {
            self.password = $.cookie('password'); 
            return true;
        }
        return false;
    }

    this.logout = function () {
        $.cookie('user',null);
        $.cookie('password',null);
        $.cookie('remember',null);
        return true; // in order not to disable the link
    }

    this.run = function() {
	    if ( self.getUserFromCookie() ) {
	    	self.showUserConsumption();
        } else {
            self.showLoginView();
        }
        $('#blackpage').fadeOut();
    }

    this.showUserConsumption = function() {
        this.showView('consumption');
    }

    this.showLoginView = function() {
        this.showView("login");
    }
    // Add capitalize function to String objects
    String.prototype.capitalize = function() {
        return this.charAt(0).toUpperCase() + this.slice(1);
    }

    // This function enable a nice shortcut to show a view
    // self.showView('login')
    // will load the /static/js/view/login.js file dynamically (if needed)
    // then create an instance of LoginView class named loginView
    // and finally launch the loginView.show() method
    this.showView = function(viewName) {
        var self=this;
        viewObjectName=viewName+"View";
        viewClassName=viewName.capitalize()+"View";
        viewFileName=viewName+".js"

        eval( "if ( typeof(self."+viewObjectName+") == \"undefined\" ) {" +
            "$.getScript('/static/js/views/"+viewFileName+"',function(){" +
                    "self."+viewObjectName+" = new "+viewClassName+"();" +
                    "self."+viewObjectName+".show();" +
                "});" +
        "} else {" +
            "self."+viewObjectName+".show();" +
        "}");
    }
}

var mainApplication = new MainApplication();

// after document loaded
$(document).ready(function(){ 
    mainApplication.run();
});

