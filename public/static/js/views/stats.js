var StatsView = function() {
    this.user = mainApplication.user;
    this.password = mainApplication.password;
    this.login_params = { l: this.user, p: this.password, v:2 };

    this.chartDatas=[[]];
    this.chartDatasFrom=[];
    this.chartDatasTo=[];
    this.chartDatasMax=3000;
}

StatsView.prototype.show = function(){
    var self=this;
    $('#menu').load('/static/html/menu.html');

    var files=[];
    var tests=[];

    files.push('/static/js/date.js');
    tests.push('Date.prototype.setISO8601');

    files.push('/static/js/flot/jquery.flot.js');
    tests.push('$.flot');
    mainApplication.run_after_dependencies( files, tests, 
            function() {
               $('#content').load("/static/html/user_stats.html",
                   function(){ self.htmlLoaded(self);});
               });

}

StatsView.prototype.htmlLoaded = function(self) {
    self.showLineChartSubview();
}

StatsView.prototype.showLineChartSubview = function() {
    var self=this;
    $.getJSON(  '/users/'+self.user+'/sensors.json', 
                self.login_params,
                function(json) {
				    self.sensor=json[0]["sensor_hr"];
                    self.getChartDatas();
                });
}

StatsView.prototype.getChartDatas = function() {
    var self=this;

    var now=new Date();

    // set the ( from -> to ) parameters for charts 0
    var chartIndex=0; 
    self.chartDatasFrom[chartIndex]=now.n_hours_ago(1);
    self.chartDatasTo[chartIndex]=now;
    self.getChartDataForIndex(chartIndex);
}

StatsView.prototype.getChartDataForIndex = function (index) {
    var self=this;
    var params={from:       self.chartDatasFrom[index].toString(),
                to:         self.chartDatasTo[index].toString(),
                interval:   5};
    for ( key in self.login_params) { 
        params[key]=self.login_params[key]; 
    }
    $.getJSON('/users/'+self.user+'/sensors/'+self.sensor+'/measures.json', 
            params,
            function(measure) { 
                self.initData( self.chartDatasFrom[index].getTime(), measure, index ); });
}

StatsView.prototype.initData = function (from, data, chartIndex) {
    var self=this;

    tab=self.chartDatas[chartIndex];
    var interval=data["interval"];

    $.each(data["data"],function(index, value) {
	    if (index) {
            tab[index]= [ from + (index*interval*1000), value==-1?null:value ];
	    }
    });
    if ( data["max"] > self.chartDatasMax ) {
        self.chartDatasMax=data["max"];
    }
    self.draw_graphic();
}

StatsView.prototype.draw_graphic = function() {
    var self=this;
    // draw something inside $('#graph')
    var from=((new Date()).midnight()).getTime();
    var to=(((new Date()).n_days_ago(-1)).midnight()).getTime();

    var maximum = self.chartDatasMax;
    maximum=Math.ceil(maximum/1000) * 1000;

    $.plot($('#graph'), [ 
            { color: "#CFF", data: self.chartDatas[0], lines: {show: true, fill: true}, label: "Today" },
            { color: "#555", data: self.chartDatas[1], lines: {show: true, fill: false}, label: "Yesterday" }
                            ], 
            {  
                xaxis: {
	                mode: "time",
	                min: from,
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

function initYesterdayData(data) {
    var interval=data["interval"];
    var from=last_midnight;
    var to=next_midnight;
    secondaryData=[];
    $.each(data["data"],function(index, value) {
	    if (index) {
            secondaryData.push( [ from.getTime() + (index*interval*1000), value==-1?null:value ] );
	    }
    });
    secondaryDataMax=data["max"];
    draw_graphic(interval);
}

*/
