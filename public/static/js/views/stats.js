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
    $('#titles h1').html('Welcome ' + mainApplication.user);
    $('#pageNavbar').load('/static/html/menu.html');

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
    $('#weekButton').click(function(){self.showWeek()});
    $('#dayButton').click(function(){self.showDay()});
    $('#hourButton').click(function(){self.showLastHour()});
}

StatsView.prototype.showLineChartSubview = function() {
    var self=this;
    $.getJSON(  '/users/'+self.user+'/sensors.json', 
                self.login_params,
                function(json) {
				    self.sensor=json[0]["sensor_hr"];
                    self.showLastHour();
                });
}

StatsView.prototype.showWeek = function() {
    var self=this;

    mainApplication.save('chart','week');
    self.mainLabel="Current week";
    self.secondLabel="Past week";
    $('#graph_loading').fadeIn();

    var now=new Date();
    var previous_monday=new Date().n_days_ago( now.getDay() + 7 ).midnight();
    var last_monday=new Date().n_days_ago( now.getDay() ).midnight();
    var next_monday=new Date().next_n_days( 7 - now.getDay() ).midnight();

    // set the ( from -> to ) parameters for charts 0
    var chartIndex=0; 
    self.chartDatas[chartIndex]=[];
    self.chartDatasFrom[chartIndex]=last_monday;
    self.chartDatasTo[chartIndex]=next_monday;
    self.getChartDataForIndex(chartIndex);

    chartIndex=1; 
    self.chartDatas[chartIndex]=[];
    self.chartDatasFrom[chartIndex]=previous_monday;
    self.chartDatasTo[chartIndex]=last_monday;
    self.getChartDataForIndex(chartIndex);
}
StatsView.prototype.showDay = function() {
    var self=this;

    mainApplication.save('chart','days');
    $('#graph_loading').fadeIn();

    self.mainLabel="Today";
    self.secondLabel="Yesterday";

    var yesterday_midnight=new Date().yesterday().midnight();
    var last_midnight=new Date().midnight();
    var next_midnight=new Date().tomorrow().midnight();

    // set the ( from -> to ) parameters for charts 0
    var chartIndex=0; 
    self.chartDatas[chartIndex]=[];
    self.chartDatasFrom[chartIndex]=last_midnight;
    self.chartDatasTo[chartIndex]=next_midnight;
    self.getChartDataForIndex(chartIndex);

    chartIndex=1; 
    self.chartDatas[chartIndex]=[];
    self.chartDatasFrom[chartIndex]=yesterday_midnight;
    self.chartDatasTo[chartIndex]=last_midnight;
    self.getChartDataForIndex(chartIndex);
}

StatsView.prototype.showLastHour = function() {
    var self=this;

    mainApplication.save('chart','hour');
    $('#graph_loading').fadeIn();

    var now=new Date();

    // set the ( from -> to ) parameters for charts 0
    var chartIndex=0; 
    self.chartDatas[chartIndex]=[];
    self.chartDatasFrom[chartIndex]=now.n_hours_ago(1);
    self.chartDatasTo[chartIndex]=now;
    self.getChartDataForIndex(chartIndex);

    chartIndex=1; 
    self.chartDatas[chartIndex]=[];
    // self.chartDatasFrom[chartIndex]=now.n_hours_ago(2);
    // self.chartDatasTo[chartIndex]=now.n_hours_ago(1);
    // self.getChartDataForIndex(chartIndex);
}

StatsView.prototype.getChartDataForIndex = function (index) {
    var self=this;
    var nb_points=60;
    var duration=self.chartDatasTo[index].getTime() - self.chartDatasFrom[index].getTime();
    duration = duration/1000;
    self.chartDatasInterval=Math.ceil(duration/nb_points);

    var params={from:       self.chartDatasFrom[index].toString(),
                to:         self.chartDatasTo[index].toString(),
                interval:   self.chartDatasInterval};
    for ( key in self.login_params) { 
        params[key]=self.login_params[key]; 
    }
    $.getJSON('/users/'+self.user+'/sensors/'+self.sensor+'/measures.json', 
            params,
            function(measure) { 
                self.initData( self.chartDatasFrom[0].getTime(), measure, index ); });
}

StatsView.prototype.initData = function (from, data, chartIndex) {
    var self=this;

    tab=self.chartDatas[chartIndex];
    var interval=data["interval"];

    $.each(data["data"],function(index, value) {
        tab[index]=( [ from + (index*interval*1000), value==-1?null:value ] );
    });
    if ( data["max"] > self.chartDatasMax ) {
        self.chartDatasMax=data["max"];
    }
    self.draw_graphic();
}

StatsView.prototype.draw_graphic = function() {
    var self=this;
    // draw something inside $('#graph')
    var from=self.chartDatasFrom[0].getTime() + self.chartDatasInterval*1000;
    var to=self.chartDatasTo[0].getTime() - self.chartDatasInterval*1000;

    var maximum = self.chartDatasMax;
    maximum=Math.ceil(maximum/1000) * 1000;

    var datas=[];
    if ( ( typeof self.chartDatas[1] == 'undefined' ) || 
            (self.chartDatas[1].length == 0) ) {
        datas[0] = { color: "#CFF", data: self.chartDatas[0], lines: {show: true, fill: true} };
    } else {
        datas[0] = { color: "#CFF", data: self.chartDatas[0], lines: {show: true, fill: true}, label: self.mainLabel };
        datas[1] = { color: "#555", data: self.chartDatas[1], lines: {show: true, fill: false}, label: self.secondLabel };
    }

    $.plot($('#graph'), datas, 
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
                },
                hooks: {
                           draw: function(plot, canvascontext) {
                                    $('#graph_loading').fadeOut(); }
                       }

            });

}
