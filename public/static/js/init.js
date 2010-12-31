(function() {
  var Application, mainApplication;
  Application = (function() {
    function Application() {}
    Application.prototype.user = "";
    Application.prototype.password = "";
    Application.prototype.remember = false;
    Application.prototype.log = function(msg) {
      if ((typeof console != "undefined" && console !== null) && (console.log != null)) {
        return console.log(msg);
      }
    };
    Application.prototype.save = function(info, value) {
      this.log("save('" + info + "','" + value + "')");
      return $.cookie(info, value, {
        expires: 14
      });
    };
    Application.prototype.forget = function(info) {
      this.log('forget("' + info + '")');
      return $.cookie(info, null);
    };
    Application.prototype.setRemember = function(remember) {
      if (remember) {
        this.save('user', this.user);
        this.save('password', this.password);
        return this.save('remember', true);
      } else {
        this.forget('user');
        this.forget('password');
        return this.forget('remember');
      }
    };
    Application.prototype.setUser = function(user) {
      this.user = user;
      if (this.remember) {
        return this.save('user', this.user);
      }
    };
    Application.prototype.setPassword = function(password) {
      this.password = password;
      if (this.remember) {
        return this.save('password', this.password);
      }
    };
    Application.prototype.retrieveSavedPreferences = function() {
      var self;
      self = this;
      self.remember = $.cookie('remember');
      self.user = $.cookie('user');
      if (self.user) {
        self.password = $.cookie('password');
        return true;
      }
      return false;
    };
    Application.prototype.logout = function() {
      $.cookie('user', null);
      $.cookie('password', null);
      $.cookie('remember', null);
      $.cookie('lastSelectedView', null);
      return true;
    };
    Application.prototype.run_after_dependencies = function(files, tests, action) {
      var file, self, test;
      self = this;
      if (files.length === 0) {
        return action();
      } else {
        file = files.pop();
        test = tests.pop();
        eval('o=' + test + ';');
        if (typeof o === "undefined") {
          return $.getScript(file, function() {
            return self.run_after_dependencies(files, tests, action);
          });
        } else {
          return self.run_after_dependencies(files, tests, action);
        }
      }
    };
    Application.prototype.connectionSuccessful = function(self, success, failed) {
      return $.ajax({
        url: '/users/' + self.user + '.json',
        data: {
          l: self.user,
          p: self.password
        },
        success: success,
        error: failed
      });
    };
    Application.prototype.run = function() {
      var self;
      self = this;
      if (self.retrieveSavedPreferences()) {
        self.connectionSuccessful(self, function() {
          switch ($.cookie('lastSelectedView')) {
            case 'stats':
              return self.showUserStats();
            case 'account':
              return self.showUserAccount();
            default:
              return self.showUserConsumption();
          }
        }, function() {
          return self.showLoginView();
        });
      } else {
        self.showLoginView();
      }
      return $('#blackpage').fadeOut();
    };
    Application.prototype.showUserConsumption = function() {
      $.cookie('lastSelectedView', 'consumption', {
        expires: 14
      });
      return this.showView('consumption');
    };
    Application.prototype.showUserStats = function() {
      $.cookie('lastSelectedView', 'stats', {
        expires: 14
      });
      return this.showView('stats');
    };
    Application.prototype.showUserAccount = function() {
      $.cookie('lastSelectedView', 'account', {
        expires: 14
      });
      return this.showView('account');
    };
    Application.prototype.showLoginView = function() {
      return this.showView("login");
    };
    String.prototype.capitalize = function() {
      return this.charAt(0).toUpperCase() + this.slice(1);
    };
    Application.prototype.showView = function(viewName) {
      var self, viewClassName, viewFileName, viewObjectName;
      self = this;
      viewObjectName = viewName + "View";
      viewClassName = viewName.capitalize() + "View";
      viewFileName = viewName + ".js";
      return eval("if ( typeof(self." + viewObjectName + ") == \"undefined\" ) {                $.getScript('/static/js/views/" + viewFileName + "',function(){                    self." + viewObjectName + " = new " + viewClassName + "(mainApplication);                    self." + viewObjectName + ".show();                });            } else {                self." + viewObjectName + ".show();            }");
    };
    return Application;
  })();
  mainApplication = new Application;
  $(document).ready(function() {
    return mainApplication.run();
  });
}).call(this);
