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
        $.cookie('lastSelectedView',null);
        return true; // in order not to disable the link
    }


    // execute the function action after all files are loaded only if needed
    //
    // example of usage:
    //
    // files=[]; 
    // tests=[];
    //
    // files.push('/static/js/date.js');
    // tests.push('Date.prototype.setISO8601');

    // files.push('/static/js/flot/jquery.flot.js');
    // tests.push('$.flot');
    //
    // mainApplication.run_after_dependencies( files, tests, 
    //         function() {
    //            $('#content').load("/static/html/user_stats.html",
    //                function(){ self.htmlLoaded(self);});
    //            });
    //
    //
    this.run_after_dependencies = function( files, tests, action ) {
        self=this;
        if ( files.length==0 ) {
            action();
        } else {
            file=files.pop();
            test=tests.pop();
            eval('o='+test+';');
            if ( typeof o == "undefined") {
                $.getScript(file,function() {
                    self.run_after_dependencies(files, tests, action);
                });
            } else {
                self.run_after_dependencies(files, tests, action);
            }
        }
    }

    this.run = function() {
	    if ( self.getUserFromCookie() ) {
            var lastSelectedView=$.cookie('lastSelectedView');
            if ( lastSelectedView == 'stats' ) {
	    	    self.showUserStats();
            } else {
	    	    self.showUserConsumption();
            }
        } else {
            self.showLoginView();
        }
        $('#blackpage').fadeOut();
    }

    this.showUserConsumption = function() {
        $.cookie('lastSelectedView','consumption',{expires: 14});
        this.showView('consumption');
    }

    this.showUserStats = function() {
        $.cookie('lastSelectedView','stats',{expires: 14});
        this.showView('stats');
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

