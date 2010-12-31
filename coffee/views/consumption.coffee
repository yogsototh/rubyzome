class window.ConsumptionView
    constructor: (@app) ->
        @user = @app.user;
        @password = @app.password;
        @login_params = { l: this.user, p: this.password, v:2 };
        @max_time=5 * 60 * 1000; # 5 minutes

    show: ->
        self=this;
        $('#titles h1').html('Welcome ' + self.app.user);
        $('#menu').load('/static/html/menu.html');
        files=[]
        tests=[]

        files.push('/static/js/date.js')
        tests.push('Date.prototype.setISO8601')

        self.app.run_after_dependencies( files, tests, 
                ->
                  $('#content').load("/static/html/user_consumption.html",
                                        -> self.htmlLoaded(self) );
                )

    htmlLoaded: (self) ->
        self.showInstantConsumptionSubview();

    showInstantConsumptionSubview: ->
        self = this;
        $.getJSON(  '/users/'+self.user+'.json', 
                    self.login_params,
                    (json) ->
                        message = json["status"];
                        $('#content #message strong').html(message);
                    );
        $.getJSON('/users/'+self.user+'/sensors.json', 
                    self.login_params,
                    (json) ->
                        self.sensor=json[0]["sensor_hr"];
                        self.getInstantConsumptionDatas(self);
                    );

    no_instant_data: (time) ->
        $('#instantconsumptionvalue').html("Disconnect since: "+time/(60*1000)+" seconds");
        $('#instanthourlycostvalue').html( 'n/a' );
        $('#instantdailycostvalue').html( 'n/a' );
        $('#instantmonthlycostvalue').html( 'n/a' );

    show_instant_data: (cons) ->
        KWH_COST=0.082;
        HOURLY_COST_MULTI = 0.001;
        DAILY_COST_MULTI = 0.024;
        MONTHLY_COST_MULTI = 0.720;
        $('#instantconsumptionvalue').html( cons + ' Watts' );
        $('#instanthourlycostvalue').html( (cons * KWH_COST * HOURLY_COST_MULTI).toFixed(2) + " €");
        $('#instantdailycostvalue').html( (cons * KWH_COST * DAILY_COST_MULTI).toFixed(2) + " €");
        $('#instantmonthlycostvalue').html( (cons * KWH_COST * MONTHLY_COST_MULTI).toFixed(2) + " €");

    getInstantConsumptionDatas: (self) ->
        $.getJSON( '/users/'+self.user+'/sensors/'+self.sensor+'/measures.json',
                    self.login_params,
                    (measure) ->
                        if ( not $('#instantconsumptionvalue')? )
                            len=measure["data"].length;
                            last=measure["data"][len-1];
                            datestring = measure["to"];
                            last_measure_date=(new Date()).setISO8601(datestring) ;
                            last_measure_time = last_measure_date.getTime() + last_measure_date.getTimezoneOffset() * 60 * 1000;
                            now=(new Date()).getTime() ;
                            time_without_measure = now - last_measure_time;
                            if time_without_measure > self.max_time
                                self.no_instant_data(time_without_measure);
                            else
                                self.show_instant_data(last);
                            setTimeout( 
                               ( ->  self.getInstantConsumptionDatas(self) )
                               , 2000);
                    )
