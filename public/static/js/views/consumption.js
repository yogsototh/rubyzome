var ConsumptionView = function() {
    this.user = mainApplication.user;
    this.password = mainApplication.password;
    this.login_params = { l: this.user, p: this.password, v:2 };
}

ConsumptionView.prototype.show = function(){
    var self=this;
    $('#titles h1').html('Welcome ' + mainApplication.user);
    $('#menu').load('/static/html/menu.html');
    var files=[];
    var tests=[];

    files.push('/static/js/date.js');
    tests.push('Date.prototype.setISO8601');

    mainApplication.run_after_dependencies( files, tests, 
            function() {
                $('#content').load("/static/html/user_consumption.html",
                    function(){ self.htmlLoaded(self);});
            });
}

ConsumptionView.prototype.htmlLoaded = function(self) {
    self.max_time=5 * 60 * 1000; // 5 minutes
    self.showInstantConsumptionSubview();
}

ConsumptionView.prototype.showInstantConsumptionSubview = function() {
    var self = this;
    $.getJSON(  '/users/'+self.user+'.json', 
                self.login_params,
                function(json){ 
                    message = json["status"];
                    $('#content #message strong').html(message);
                });
    $.getJSON(  '/users/'+self.user+'/sensors.json', self.login_params,
                function(json) {
				    self.sensor=json[0]["sensor_hr"];
                    self.getInstantConsumptionDatas(self);
                });
}

ConsumptionView.prototype.no_instant_data=function(time) {
    $('#instantconsumptionvalue').html("Disconnect since: "+time/(60*1000)+" seconds");
    $('#instanthourlycostvalue').html( 'n/a' );
    $('#instantdailycostvalue').html( 'n/a' );
    $('#instantmonthlycostvalue').html( 'n/a' );
}
ConsumptionView.prototype.show_instant_data=function(cons) {
    var KWH_COST=0.082;
    var HOURLY_COST_MULTI = 0.001;
    var DAILY_COST_MULTI = 0.024;
    var MONTHLY_COST_MULTI = 0.720;
    $('#instantconsumptionvalue').html( cons + ' Watts' );
    $('#instanthourlycostvalue').html( (cons * KWH_COST * HOURLY_COST_MULTI).toFixed(2) + " €");
    $('#instantdailycostvalue').html( (cons * KWH_COST * DAILY_COST_MULTI).toFixed(2) + " €");
    $('#instantmonthlycostvalue').html( (cons * KWH_COST * MONTHLY_COST_MULTI).toFixed(2) + " €");
}

ConsumptionView.prototype.getInstantConsumptionDatas = function(self) {
    $.getJSON( '/users/'+self.user+'/sensors/'+self.sensor+'/measures.json',
                self.login_params,
                function(measure) {
                    if ( typeof $('#instantconsumptionvalue') != 'undefined' ) {
                        var len=measure["data"].length;
                        var last=measure["data"][len-1];
                        var last_measure_date=(new Date(measure["to"])).getTime() ;
                        var now=(new Date()).getTime() ;
                        var time_without_measure = now - last_measure_date;
                        mainApplication.log(time_without_measure);
                        if ( time_without_measure > self.max_time ) {
                            self.no_instant_data(time_without_measure);
                        } else {
                            self.show_instant_data(last);
                        }
                        setTimeout( function() { 
                            self.getInstantConsumptionDatas(self)}, 2000);
                    }
                }
                )
}

