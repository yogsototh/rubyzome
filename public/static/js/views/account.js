(function() {
  var AccountView;
  AccountView = (function() {
    function AccountView(application) {
      this.application = application;
      this.user = this.application.user;
      this.password = this.application.password;
      this.message = "";
      this.login_params = {
        l: this.user,
        p: this.password,
        v: 2
      };
      this.num = 0;
    }
    AccountView.prototype.show = function() {
      var self;
      self = this;
      $('#titles h1').html('Welcome ' + self.application.user);
      $('#menu').load('/static/html/menu.html');
      return $('#content').load("/static/html/user_account.html", function() {
        return self.htmlLoaded(self);
      });
    };
    AccountView.prototype.htmlLoaded = function(self) {
      return self.showUserAccount();
    };
    AccountView.prototype.showUserAccount = function() {
      var self;
      self = this;
      $('#nickname').html(this.user);
      $('#password').val(this.password);
      $.getJSON('/users/' + self.user + '.json', {
        l: self.user,
        p: self.password
      }, function(json) {
        self.message = json["status"];
        return $('#message').html(self.message);
      });
      return $('#updateButton').click(function() {
        return self.update_resource(self);
      });
    };
    AccountView.prototype.update_resource = function(self) {
      var newpassword;
      newpassword = $('#password').val();
      return $.post('/accounts/' + self.user + '.json', {
        l: self.user,
        p: self.password,
        nickname: self.user,
        password: newpassword,
        _method: 'PUT'
      }, function() {
        var num;
        self.application.setPassword(newpassword);
        self.password = self.application.password;
        return num = self.num;
      }, $("#info").prepend('<div id="updated' + num + '">' + self.user + ' updated!</div>'), setTimeout(function() {
        return $('#updated' + num).remove();
      }, 1500), self.num++);
    };
    return AccountView;
  })();
}).call(this);
