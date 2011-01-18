var user = "";
var password = "";
var stat = "";

function getUserFromCookie() {
    user = $.cookie('user');
    if (user) {
        password = $.cookie('password'); 
        return true;
    }
    return false;
}

function logout() {
    $.cookie('user',null);
    $.cookie('password',null);
    $.cookie('remember',null);
    return true; // in order not to disable the link
}

function become_active() {
    $(this).removeClass('inactive');
}

function select_and_active() {
	$(this).select();
	$(this).removeClass('inactive')
}

function clearInput() {
    this.value=''; 
    this.select(); 
    $(this).removeClass('inactive');
}

function setDefaultInput(elem, defaultValue) {
    if (!elem.value) {
        elem.value=defaultValue; 
        $(elem).addClass('inactive');
    }
}


function showLoginView() {
    $('#content').load("/static/html/login.html",function(){
	    $("#username").click(clearInput);
	    $("#username").focus(clearInput);
	    $("#username").blur( function() {setDefaultInput(this,"User Name");});
	    $("#password").click(clearInput);
	    $("#password").focus(clearInput)

	    $('form[name=login_form]').submit(function (){
	    	user = $('[name=l]').val();
	    	password = $('[name=p]').val();
            if ($('#remember').attr('checked')) {
                $.cookie('user',user,{expires: 14});
                $.cookie('password',password,{expires: 14});
                $.cookie('remember',true,{expires: 14});
            } else {
                $.cookie('user',null);
                $.cookie('password',null);
                $.cookie('remember',true,null);
            }
	    	showUserConsumption();
	    	return false;
            });
    });
}

// after document loaded
$(document).ready(function(){ 
	if ( getUserFromCookie() ) {
		showUserConsumption();
    } else {
        showLoginView();
    }
    $('#blackpage').fadeOut();
});

function showUserConsumption(){
	
	var params = getUrlVars();
	var prefix_url='/users/'+user+'/sensors';
	var login_param = { "l": user, "p" : password };


	$.ajax({url: prefix_url+'.json', 
		data: login_param , 
		success: function(json){
			$('#content').load("/static/html/user_consumption.html",function(){
				// $('#username strong').html(user);

				$.getJSON('/users/' + user + '.json',
					  login_param,
					  function(usr){
						stat = usr["status"];
						$('#content #message strong').html(stat);
					  }
				);

				// only for first sensor
				sensor=json[0]["sensor_hr"];
				var last_measure_param = { "l": user, "p" : password, "v": 2 };

                update_dates();
				var last_day_measure_param = { "l": user, "p" : password, "from" : last_midnight.toString(), "v": 2, "to": next_midnight.toString(), interval: 300 };

				var past_day_measure_param = { "l": user, "p" : password, "from" : preceeding_midnight.toString(), "v": 2, "to": last_midnight.toString(), interval: 300 };
                update_today_graphic(prefix_url, user, password, sensor, last_day_measure_param);
                update_yesterday_graphic(prefix_url, user, password, sensor, past_day_measure_param);
                update_instant_consumption(prefix_url, user, password, sensor, last_measure_param);
                $('#dayButton').addClass('selected');
				showMenu();
				showTitle();
				return false;	
			});
		},
		error: function(){
	    		$("#info").prepend('<div id="error">Authentication failed</div>');
	    		setTimeout(function(){$('#error').remove()},2000);
		}
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

Date.prototype.setISO8601 = function (string) {
    var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
    "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
    "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
    var d = string.match(new RegExp(regexp));

    var offset = 0;
    var date = new Date(d[1], 0, 1);

    if (d[3]) { date.setMonth(d[3] - 1); }
    if (d[5]) { date.setDate(d[5]); }
    if (d[7]) { date.setHours(d[7]); }
    if (d[8]) { date.setMinutes(d[8]); }
    if (d[10]) { date.setSeconds(d[10]); }
    if (d[12]) { date.setMilliseconds(Number("0." + d[12]) * 1000); }
    if (d[14]) {
	offset = (Number(d[16]) * 60) + Number(d[17]);
	offset *= ((d[15] == '-') ? 1 : -1);
    }

    offset -= date.getTimezoneOffset();
    time = (Number(date) + (offset * 60 * 1000));
    this.setTime(Number(time));
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

function initTodayData(data) {
    var interval=data["interval"];
    var from=last_midnight;
    var to=next_midnight;
    todayData=[];
    $.each(data["data"],function(index, value) {
	    if (index) {
            todayData[index]=[ from.getTime() + (index*interval*1000), value==-1?null:value ];
	    }
    });
    maxToday=data["max"];
    draw_graphic(interval);
}

function draw_graphic(interval) {
    // draw something inside $('#graph')
    var from=last_midnight;
    var to=next_midnight;

    var maximum = maxToday>maxYesterday ? maxToday : maxYesterday;
    maximum=Math.ceil(maximum/1000) * 1000;

    $.plot($('#graph'), [ 
            { color: "#CFF", data: todayData, lines: {show: true, fill: true}, label: "Today" },
            { color: "#555", data: yesterdayData, lines: {show: true, fill: false}, label: "Yesterday" }
                            ], 
            {  
                xaxis: {
	                mode: "time",
	                min: from.getTime()+interval*1000,
	                max: to.getTime()
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

var now;
var one_day_ago;
var preceeding_midnight;
var yesterday_midnight;
var last_midnight;
var next_midnight;

function update_dates() {
    now=new Date;
    one_day_ago=new Date((new Date).getTime() - 24*60*60*1000);
    preceeding_midnight=new Date(one_day_ago.getFullYear(), one_day_ago.getMonth(), one_day_ago.getDate(), 0, 0, 0, 0);
    yesterday_midnight=new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    last_midnight=new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    next_midnight=new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
}

update_dates();

