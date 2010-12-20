var MainApplication = function () {
    self=this;
    this.user="";
    this.password="";

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
            console.log('User = ' + self.user);
            console.log('Pass = ' + self.password);
	    	self.showUserConsumption();
        } else {
            self.showLoginView();
        }
        $('#blackpage').fadeOut();
    }

    this.showUserConsumption = function() {
        /*
        if ( typeof(self.consumptionView) = "undefined" ) {
            $.getScript('/static/js/views/consumption.js',function(){
                    self.consumptionView = new ConsumptionView();
                    self.consumptionView.show();
                });
        } else {
            self.loginView.show();
        }
        */
        self.showView('consumption');
    }

    this.showLoginView = function() {
        if ( typeof(self.loginView) == "undefined" ) {
            $.getScript('/static/js/views/login.js',function(){
                    self.loginView = new LoginView();
                    self.loginView.show();
                });
        } else {
            self.loginView.show();
        }
        // self.showView("login");

    }

    // Add capitalize function to String objects
    String.prototype.capitalize = function() {
        return this.charAt(0).toUpperCase() + this.slice(1);
    }

    this.showView = function(viewName) {
        viewObjectName=viewName+"View";
        viewClassName=viewName.capitalize()+"View";
        viewFileName=viewName+".js"

        eval( "if ( typeof(self."+viewObjectName+") == \"undefined\" ) {" +
            "$.getScript('/static/js/views/"+viewFileName+"',function(){" +
                    "self."+viewObjectName+" = new "+viewClassName+"();" +
                    "self."+viewObjectName+".show();" +
                "});" +
        "} else {" +
            "self."+viewName+"View.show();" +
        "}");
    }
}

var mainApplication = new MainApplication();

// after document loaded
$(document).ready(function(){ 
    mainApplication.run();
});

