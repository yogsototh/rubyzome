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
    self.chartDatas[chartIndex]=[];
    self.chartDatasFrom[chartIndex]=now.n_hours_ago(1);
    self.chartDatasTo[chartIndex]=now;
    self.getChartDataForIndex(chartIndex);

    // chartIndex=1; 
    // self.chartDatas[chartIndex]=[];
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
        datas[0] = { color: "#CFF", data: self.chartDatas[0], lines: {show: true, fill: true}, label: "Today" };
        datas[1] = { color: "#555", data: self.chartDatas[1], lines: {show: true, fill: false}, label: "Yesterday" };
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
                }

            });
}
