// DEBUG MODE

var debug=true;
if (debug) {
    // Replace the normal jQuery getScript function with one that supports
    // debugging and which references the script files as external resources
    // rather than inline.
    jQuery.extend({
        getScript: function(url, callback) {
            var head = document.getElementsByTagName("head")[0];
            var script = document.createElement("script");
            script.src = url;

            // Handle Script loading
            {
                var done = false;

                // Attach handlers for all browsers
                script.onload = script.onreadystatechange = function(){
                    if ( !done && (!this.readyState ||
                            this.readyState == "loaded" || this.readyState == "complete") ) {
                        done = true;
                        if (callback)
                        callback();

                        // Handle memory leak in IE
                        script.onload = script.onreadystatechange = null;
                    }
                };
            }

            head.appendChild(script);

            // We handle everything using the script element injection
            return undefined;
        },
    });
}

var MainApplication = function () {
    self=this;
    this.user="";
    this.password="";
    this.remember=false;

    this.log = function(msg) {
        if (typeof console != 'undefined') {
            if (typeof console.log != 'undefined') {
                console.log(msg);
            }
        }
    }

    this.save = function (info,value) { 
        this.log('save("'+info+'","'+value+'")');
        $.cookie(info,value,{expires: 14}); 
    }
    this.forget = function (info) { 
        this.log('forget("'+info+'")');
        $.cookie(info,null); 
    }

    this.setRemember = function(remember) { 
        if (remember) {
            this.save('user',this.user);
            this.save('password',this.password);
            this.save('remember',true);
        } else {
            this.forget('user');
            this.forget('password');
            this.forget('remember');
        }
    }

    this.setUser = function(user) { 
        this.user = user; 
        if (this.remember) {
            this.save('user',this.user);
        } 
    }

    this.setPassword = function(password) { 
        this.password = password; 
        if (this.remember) {
            this.save('password',this.password);
        } 
    }

    this.retrieveSavedPreferences = function() {
        var self=this;
        self.remember = $.cookie('remember');
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
    //
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

    this.connectionSuccessful = function(self, success, failed ) {
        $.ajax({url: '/users/'+self.user+'.json',
                data: {l: self.user, p: self.password},
                success: success,
                error: failed
                });
    }

    this.run = function() {
        var self=this;
	    if ( self.retrieveSavedPreferences() ) {
            self.connectionSuccessful(
                    self,
                    function() {
                        var lastSelectedView=$.cookie('lastSelectedView');
                        if ( lastSelectedView == 'stats' ) {
	    	                self.showUserStats();
                        } else if ( lastSelectedView == 'account' ) {
	    	                self.showUserAccount();
                        } else {
	    	                self.showUserConsumption();
                        }
                    },
                    function() { self.showLoginView() } );
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

    this.showUserAccount = function() {
        $.cookie('lastSelectedView','account',{expires: 14});
        this.showView('account');
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

