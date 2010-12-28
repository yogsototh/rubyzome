var ConsumptionView = function() {
    this.user = mainApplication.user;
    this.password = mainApplication.password;
    this.login_params = { l: this.user, p: this.password, v:2 };

    this.chartDatas=[[]];
    this.chartDatasFrom=[null];
    this.chartDatasTo=[null];
    this.chartDataMax=3000;
}

ConsumptionView.prototype.show = function(){
    var self=this;
    $('#menu').load('/static/html/menu.html');
    $.getScript('/static/js/date.js', function(){
        $('#content').load("/static/html/user_consumption.html",
                            function(){ self.htmlLoaded(self);});
    })
}

ConsumptionView.prototype.htmlLoaded = function(self) {
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
                    self.getInstantConsumptionDatas();
                });
}

ConsumptionView.prototype.getInstantConsumptionDatas = function() {
    var self=this;
    $.getJSON( '/users/'+self.user+'/sensors/'+self.sensor+'/measures.json',
                self.login_params,
                function(measure) {
					var len=measure["data"].length;
					var last=measure["data"][len-1];
                    // var last_measure_date=new Date.parse( measure["date"] ) ;
                    // if ( last_measure_date - now > max_time ) {
                    //  no_instant_data();
                    // }

					var cons=last;
					var KWH_COST=0.082;
					var HOURLY_COST_MULTI = 0.001;
					var DAILY_COST_MULTI = 0.024;
					var MONTHLY_COST_MULTI = 0.720;
					$('#instantconsumptionvalue').html( cons + ' Watts' );
					$('#instanthourlycostvalue').html( (cons * KWH_COST * HOURLY_COST_MULTI).toFixed(2) + " €");
					$('#instantdailycostvalue').html( (cons * KWH_COST * DAILY_COST_MULTI).toFixed(2) + " €");
					$('#instantmonthlycostvalue').html( (cons * KWH_COST * MONTHLY_COST_MULTI).toFixed(2) + " €");
                }
                )
}

