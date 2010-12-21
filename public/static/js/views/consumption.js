var ConsumptionView = function() {
    this.user = mainApplication.user;
    this.password = mainApplication.password;
    this.login_params = { l: this.user, p: this.password, v:2 };
    this.todayData=[];
    this.yesterdayData=[];
    this.now = new Date();
    this.midnight = null;
    this.tonight_midnight = null;
    this.maxToday=3000;
    this.maxYesterday=3000;
}

ConsumptionView.prototype.show = function(){
    var self=this;
    $.getScript('/static/js/date.js', function(){
        $('#content').load("/static/html/user_consumption.html",
                            function(){ self.htmlLoaded(self);});
    })
}

ConsumptionView.prototype.htmlLoaded = function(self) {
    self.showInstantConsumptionSubview();
    self.showLineChartSubview();
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

ConsumptionView.prototype.showLineChartSubview = function() {
    var self=this;
    $.getJSON(  '/users/'+self.user+'/sensors.json', 
                self.login_params,
                function(json) {
				    self.sensor=json[0]["sensor_hr"];
                    self.getChartDatas();
                });
}

ConsumptionView.prototype.getChartDatas = function() {
    var self=this;

    self.now=new Date();
    self.midnight=self.now.midnight();
    tomorrow=self.now.n_days_ago(-1);
    self.tonight_midnight=tomorrow.midnight();

    var params={from:       self.midnight.toString(),
                to:         self.tonight_midnight.toString(), 
                interval:   300};
    for ( key in self.login_params) { 
        params[key]=self.login_params[key]; 
    }

    $.getJSON('/users/'+self.user+'/sensors/'+self.sensor+'/measures.json', 
            params,
            function(measure) { self.initTodayData( measure ); });
}

ConsumptionView.prototype.initTodayData = function (data) {
    var self=this;

    self.todayData=[];
    var interval=data["interval"];

    var from=self.midnight.getTime();
    $.each(data["data"],function(index, value) {
	    if (index) {
            self.todayData[index]=
                [ from + (index*interval*1000), value==-1?null:value ];
	    }
    });
    self.maxToday=data["max"];
    self.draw_graphic();
}

ConsumptionView.prototype.draw_graphic = function() {
    var self=this;
    // draw something inside $('#graph')
    var from=self.last_midnight.getTime();
    var to=self.next_midnight.getTime();

    var maximum = self.maxToday>self.maxYesterday ? self.maxToday : self.maxYesterday;
    maximum=Math.ceil(maximum/1000) * 1000;

    $.plot($('#graph'), [ 
            { color: "#CFF", data: self.todayData, lines: {show: true, fill: true}, label: "Today" },
            { color: "#555", data: self.yesterdayData, lines: {show: true, fill: false}, label: "Yesterday" }
                            ], 
            {  
                xaxis: {
	                mode: "time",
	                min: from+self.interval*1000,
	                max: to
	            },
                yaxis: { min: 0, max: maximum}, 
                grid: {
                    color: '#888',
                    backgroundColor: {
                        colors: ['#011111','#010101']} 
                },
                legend: {
                    labelBoxBorderColor: '#000',
                    position: 'nw',
                    margin: 0,
                    backgroundColor: '#222',
                    backgroundOpacity: 0.9 
                }

            });
}

/* AFTER THIS LINE THE CODE IS GARBLED FOR NOW */
   /* 
var last_measure_param = { "l": user, "p" : password, "v": 2 };
update_dates();
var last_day_measure_param = { "l": user, "p" : password, "from" : last_midnight.toString(), "v": 2, "to": next_midnight.toString(), interval: 300 };

				var past_day_measure_param = { "l": user, "p" : password, "from" : preceeding_midnight.toString(), "v": 2, "to": last_midnight.toString(), interval: 300 };
                update_today_graphic(prefix_url, user, password, sensor, last_day_measure_param);
                update_yesterday_graphic(prefix_url, user, password, sensor, past_day_measure_param);
                $('#dayButton').addClass('selected');
				showMenu();
				showTitle();
				return false;	
			});
}

function update_today_graphic(prefix_url, user, password, sensor, last_day_measure_param) {
        if ( $('#instantconsumptionvalue').length > 0 ) {
				$.getJSON(prefix_url+'/'+sensor+'/measures.json', last_day_measure_param, function(measure) {
					initTodayData( measure );
				});
            setTimeout(function() {update_graphic(prefix_url,user,password,sensor,last_day_measure_param);}, 300000);
        }
}
function update_yesterday_graphic(prefix_url, user, password, sensor, past_day_measure_param) {
        if ( $('#instantconsumptionvalue').length > 0 ) {
				$.getJSON(prefix_url+'/'+sensor+'/measures.json', past_day_measure_param, function(measure) {
					initYesterdayData( measure );
				});
            setTimeout(function() {update_graphic(prefix_url,user,password,sensor,last_day_measure_param);}, 300000);
        }
}
function update_instant_consumption(prefix_url, user, password, sensor, last_measure_param) {
        if ( $('#instantconsumptionvalue').length > 0 ) {
				$.getJSON(prefix_url+'/'+sensor+'/measures.json', last_measure_param, function(measure) {
					var len=measure["data"].length;
					var last=measure["data"][len-1];

					//var cons=last["consumption"]
					var cons=last;
					var KWH_COST=0.082;
					var HOURLY_COST_MULTI = 0.001;
					var DAILY_COST_MULTI = 0.024;
					var MONTHLY_COST_MULTI = 0.720;
					$('#instantconsumptionvalue').html( cons + ' Watts' );
					$('#instanthourlycostvalue').html( (cons * KWH_COST * HOURLY_COST_MULTI).toFixed(2) + " €");
					$('#instantdailycostvalue').html( (cons * KWH_COST * DAILY_COST_MULTI).toFixed(2) + " €");
					$('#instantmonthlycostvalue').html( (cons * KWH_COST * MONTHLY_COST_MULTI).toFixed(2) + " €");
				});
            setTimeout(function() {update_instant_consumption(prefix_url,user,password,sensor,last_measure_param);}, 3000);
        }
}
function showUserAccount(){
	$('#content').load('/static/html/user_account.html', function(){
		tr = $('<tr class="r0" id="line' + user + '"><td>' + user + '</td><td><input type="text" id="pw' + user + '"  value="' + password + '"/></td> <td>' + stat + '</td> <td><span class="button" onclick="update_resource(\'account\',\'' + user + '\')">update</span></td></tr>');

                $('#account').append(tr);

		// Only allow user to modify his password
		$('#pw'+user).click(function(){
			$('#pw'+user).addClass('editable');
		});
		$('#pw'+user).blur(function() {
			$('#pw'+user).removeClass('editable');
		});

		return false;
	});
}

function showMenu(){
	$('#menu').load('/static/html/menu.html');
}	

function showTitle(){
	$('#titles h1').html('Hello ' + user);
}

var num=0;

function update_resource(type, nickname) {
    base = '/' + type + 's/';
    $.post(
	base+nickname+'.json', 
	{   l: user,
	    p: password,
	    nickname: nickname, 
	    password: $('#pw'+user).val(),
	    _method: 'PUT'
	},
	function() {
	    var name='s'+num+'_'+nickname;
	    password = $('#pw'+user).val();
	    $("#info").prepend('<div id="'+name+'">'+nickname+' updated!</div>');
	    setTimeout(function(){$('#'+name).remove()},1500);
	    num++;
	});
}

function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
	hash = hashes[i].split('=');
	vars.push(hash[0]);
	vars[hash[0]] = hash[1];
    }
    return vars;
}


var todayData=[];
var yesterdayData=[];
var maxToday=3000;
var maxYesterday=3000;

function initYesterdayData(data) {
    var interval=data["interval"];
    var from=last_midnight;
    var to=next_midnight;
    yesterdayData=[];
    $.each(data["data"],function(index, value) {
	    if (index) {
            yesterdayData.push( [ from.getTime() + (index*interval*1000), value==-1?null:value ] );
	    }
    });
    maxYesterday=data["max"];
    draw_graphic(interval);
}

*/
