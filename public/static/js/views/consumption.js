var ConsumptionView = function() {
    this.user = mainApplication.user;
    this.password = mainApplication.password;
    this.login_params = { l: this.user, p: this.password, v:2 };
}

ConsumptionView.prototype.show = function(){
    var self=this;
    $('#titles h1').html('Welcome ' + mainApplication.user);
    $('#pageNavbar').load('/static/html/menu.html');
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

ConsumptionView.prototype.no_instant_data=function(last_measure_date,time_without_measure) {
    var self=this;
    var message="<div>Disconnected</div>";
    var nb_days=Math.ceil( time_without_measure / ( 1000 * 60 * 60 * 24 ) ) - 1;
    if ( nb_days > 0 ) {
        if ( nb_days == 1 ) {
            message+=nb_days+" day ago";
        } else {
            message+=nb_days+" days ago";
        }
    } else  {
        var d=new Date(time_without_measure);
        if (d.getHours()>0) {
            message+=d.getHours()+" hours ago"
        } else if (d.getMinutes()>0) {
            message+=d.getMinutes()+" minutes ago";
        } else {
            message+=d.getSeconds()+" seconds ago";
        }
    }
    message+="<div style=\"margin-top: 1em;font-size: .5em;\">Last measure date: <br/>"+last_measure_date+"</div>";
        
    $('#instantconsumptionvalue').html(message);
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
    var i=1;
    var cons_color="#4C4";
    while (i< Math.floor( ( cons * 16 ) / 3500 )) {
        mainApplication.log('#consumptionAnalogic table tr.c'+i+' td');
        $('#consumptionAnalogic table tr.c'+i+' td').css({backgroundColor: cons_color});
        if (i>4) cons_color="#4CC";
        if (i>8) cons_color="#CC4";
        if (i>12) cons_color="#C44";
        i++;
    }
}

ConsumptionView.prototype.getInstantConsumptionDatas = function(self) {

    if ( typeof $('#instantconsumptionvalue') == "undefined" ) {
        return false;                 
    }
    $.getJSON( '/users/'+self.user+'/sensors/'+self.sensor+'/measures.json',
                self.login_params,
                function(measure) {
                    if ( typeof $('#instantconsumptionvalue') != 'undefined' ) {
                        var len=measure["data"].length;
                        var last=measure["data"][len-1];
                        // var datestring=measure["to"].slice(0,19).replace('T',' ')+' GMT';
                        var datestring = measure["to"];
                        var last_measure_date=(new Date()).setISO8601(datestring) ;
                        var last_measure_time = last_measure_date.getTime() + ( (new Date()).getTimezoneOffset() - last_measure_date.getTimezoneOffset() )*60*60*1000;
                        var now=(new Date()).getTime() ;
                        var time_without_measure = now - last_measure_time;
                        // if ( time_without_measure > self.max_time ) {
                        //     self.no_instant_data(last_measure_date,time_without_measure);
                        // } else {
                            self.show_instant_data(last);
                        // }
                        setTimeout( function() { 
                            self.getInstantConsumptionDatas(self)}, 2000);
                    }
                }
                )
}

