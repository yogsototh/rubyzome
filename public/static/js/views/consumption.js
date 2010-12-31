(function() {
  window.ConsumptionView = (function() {
    function ConsumptionView(app) {
      this.app = app;
      this.user = this.app.user;
      this.password = this.app.password;
      this.login_params = {
        l: this.user,
        p: this.password,
        v: 2
      };
      this.max_time = 5 * 60 * 1000;
    }
    ConsumptionView.prototype.show = function() {
      var files, self, tests;
      self = this;
      $('#titles h1').html('Welcome ' + self.app.user);
      $('#menu').load('/static/html/menu.html');
      files = [];
      tests = [];
      files.push('/static/js/date.js');
      tests.push('Date.prototype.setISO8601');
      return self.app.run_after_dependencies(files, tests, function() {
        return $('#content').load("/static/html/user_consumption.html", function() {
          return self.htmlLoaded(self);
        });
      });
    };
    ConsumptionView.prototype.htmlLoaded = function(self) {
      return self.showInstantConsumptionSubview();
    };
    ConsumptionView.prototype.showInstantConsumptionSubview = function() {
      var self;
      self = this;
      $.getJSON('/users/' + self.user + '.json', self.login_params, function(json) {
        var message;
        message = json["status"];
        return $('#content #message strong').html(message);
      });
      return $.getJSON('/users/' + self.user + '/sensors.json', self.login_params, function(json) {
        self.sensor = json[0]["sensor_hr"];
        return self.getInstantConsumptionDatas(self);
      });
    };
    ConsumptionView.prototype.no_instant_data = function(time) {
      $('#instantconsumptionvalue').html("Disconnect since: " + time / (60 * 1000) + " seconds");
      $('#instanthourlycostvalue').html('n/a');
      $('#instantdailycostvalue').html('n/a');
      return $('#instantmonthlycostvalue').html('n/a');
    };
    ConsumptionView.prototype.show_instant_data = function(cons) {
      var DAILY_COST_MULTI, HOURLY_COST_MULTI, KWH_COST, MONTHLY_COST_MULTI;
      KWH_COST = 0.082;
      HOURLY_COST_MULTI = 0.001;
      DAILY_COST_MULTI = 0.024;
      MONTHLY_COST_MULTI = 0.720;
      $('#instantconsumptionvalue').html(cons + ' Watts');
      $('#instanthourlycostvalue').html((cons * KWH_COST * HOURLY_COST_MULTI).toFixed(2) + " €");
      $('#instantdailycostvalue').html((cons * KWH_COST * DAILY_COST_MULTI).toFixed(2) + " €");
      return $('#instantmonthlycostvalue').html((cons * KWH_COST * MONTHLY_COST_MULTI).toFixed(2) + " €");
    };
    ConsumptionView.prototype.getInstantConsumptionDatas = function(self) {
      return $.getJSON('/users/' + self.user + '/sensors/' + self.sensor + '/measures.json', self.login_params, function(measure) {
        var datestring, last, last_measure_date, last_measure_time, len, now, time_without_measure;
        if (!($('#instantconsumptionvalue') != null)) {
          len = measure["data"].length;
          last = measure["data"][len - 1];
          datestring = measure["to"];
          last_measure_date = (new Date()).setISO8601(datestring);
          last_measure_time = last_measure_date.getTime() + last_measure_date.getTimezoneOffset() * 60 * 1000;
          now = (new Date()).getTime();
          time_without_measure = now - last_measure_time;
          if (time_without_measure > self.max_time) {
            self.no_instant_data(time_without_measure);
          } else {
            self.show_instant_data(last);
          }
          return setTimeout((function() {
            return self.getInstantConsumptionDatas(self);
          }), 2000);
        }
      });
    };
    return ConsumptionView;
  })();
}).call(this);
