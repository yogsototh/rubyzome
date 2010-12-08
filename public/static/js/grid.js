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
    return true; // in order not to disable the link
}

function become_active() {
    $(this).removeClass('inactive');
}

function select_and_active() {
	$(this).select();
	$(this).removeClass('inactive')
}

// after document loaded
$(document).ready(function(){ 
	if ( getUserFromCookie() ) {
		showUserConsumption();
    } else {
	    $("#username").click(function() { $(this).select(); $(this).removeClass('inactive'); });
	    $("#username").focus(function() { $(this).select(); $(this).removeClass('inactive'); });
	    $("#password").click(function() { $(this).select(); $(this).removeClass('inactive'); });
	    $("#password").focus(function() { $(this).select(); $(this).removeClass('inactive'); });

	    $('#username').change(function(){
	    	if ( $(this).val() == '' || $(this).val() == 'User Name') {
	    		$(this).val('User Name');
	    		$(this).addClass('inactive');
	    	}
	    });

	    $('#password').change(function(){
	    	if ( $(this).val() == '' ) {
	    		$(this).val('password');
	    		$(this).addClass('inactive');
	    	}
	    });

	    $('form[name=login_form]').submit(function (){
	    	user = $('[name=l]').val();
	    	password = $('[name=p]').val();
            $.cookie('user',user);
            $.cookie('password',password);
	    	showUserConsumption();
	    	return false;
            });
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
				$('#username strong').html(user);

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
				var last_day_measure_param = { "l": user, "p" : password, "from" : one_day_ago.toString(), "v": 2, "to": now.toString(), interval: 1800 };
				$.getJSON(prefix_url+'/'+sensor+'/measures.json', last_day_measure_param, function(measure) {
					draw_graphic( measure );
				});
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

function draw_graphic( data ) {
    // draw something inside $('#graph')
    var from=new Date();
    var to=new Date();
    from.setISO8601(data["from"]);
    to.setISO8601(data["to"]);
    var datatabs=new Array();
    var interval=data["interval"];
    $.each(data["data"],function(index, value) {
	if (index) {
	    datatabs[index]=[ from.getTime() + (index*interval*1000), value ];
	}
    });
    $.plot($('#graph'), [{color: "#CFF", data: datatabs, lines: {show: true, fill: true}}], {  
            xaxis: {
	            mode: "time",
	            min: from.getTime()+interval*1000,
	            max: to.getTime()
	        },
	        yaxis: { min: 0, max: 3000 } });
}

var now=new Date
var one_day_ago=new Date((new Date).getTime() - 24 * 3600000)
