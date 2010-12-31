(function() {
  window.LoginView = (function() {
    function LoginView(app) {
      this.app = app;
    }
    LoginView.prototype.show = function() {
      var self;
      self = this;
      $('#titles h1').html('Sign in');
      return $('#content').load("/static/html/login.html", function() {
        return self.htmlLoaded(self);
      });
    };
    LoginView.prototype.handleCookie = function() {
      if ($('#remember').attr('checked')) {
        return this.app.setRemember(true);
      } else {
        return this.app.setRemember(false);
      }
    };
    LoginView.prototype.formSubmitted = function() {
      var self;
      self = this;
      self.app.setUser($('[name=l]').val());
      self.app.setPassword($('[name=p]').val());
      self.handleCookie();
      $.ajax({
        url: '/users/' + self.app.user + '.json',
        data: {
          "l": self.app.user,
          "p": self.app.password
        },
        success: function() {
          return self.app.showUserConsumption();
        },
        error: function() {
          $("#info").prepend('<div id="error">Authentication failed</div>');
          return setTimeout((function() {
            return $('#error').remove();
          }), 2000);
        }
      });
      return false;
    };
    LoginView.prototype.htmlLoaded = function(self) {
      self.autoclear('username', 'User Name');
      self.autoclear('password', '');
      return $('form[name=login_form]').submit(function() {
        return self.formSubmitted();
      });
    };
    LoginView.prototype.clear = function() {
      this.value = '';
      this.select();
      return $(this).removeClass('inactive');
    };
    LoginView.prototype.inputDefaultValue = function(o, defaultValue) {
      var self;
      self = this;
      self.app.log('inputDefaultValue: ' + defaultValue);
      if (o.value === '') {
        o.value = defaultValue;
        return $(o).addClass('inactive');
      }
    };
    LoginView.prototype.autoclear = function(id, defaultValue) {
      var self;
      self = this;
      $('#' + id).click(self.clear);
      $('#' + id).focus(self.clear);
      return $('#' + id).blur(function() {
        return self.inputDefaultValue(this, defaultValue);
      });
    };
    return LoginView;
  })();
}).call(this);
