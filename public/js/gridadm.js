var user = "";
var password = "";

function getUserFromCookie() {
    user = $.cookie('user');
    if (user) {
        password = $.cookie('password'); 
        $('#username').val(user).become_active();
        $('#password').val(password).become_active();
        return false;
    }
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
	getUserFromCookie();

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
		showUsersList();
		showMenu();
		return false;
        });
});

function showList(type){
    if (type == 'user'){showUsersList();}
    if (type == 'account'){showAccountsList();}
}

function showUsersList(){
/*
	$.getJSON('/users.json',
		{l: user, p: password},
		function(data){
		    buildUsersList(data);
		    return false;
	        });
*/
	$.ajax({url: '/users.json',
	        data: {l: user, p: password},
		success: function(data){
		    buildUsersList(data);
		    return false;
	        },
	  	error: function(a,b,c){
	    	    $("#info").prepend('<div id="error">Authentication error !</div>');
		    setTimeout(function(){$('#error').remove()},2500);
		},
		dataType: 'json'});
}

function buildUsersList(data){
	$('#content').empty();

        // Buil table
	tab =  $('<table><tr><th>nickname</th><th>status</th><th>update</th><th>remove</th></tr>');

	parity = 0;
        var nickname, message;
	$.each(data, function(k,v){
		nickname = v['nickname'];
		message = v['status'];
		parity = (parity + 1)%2;

		tr = $('<tr class="r' + parity + '" id="line' + nickname + '"><td><a id="user' + nickname + '" href="" onclick="showUserConsumption(\'' + nickname + '\');return false;">' +nickname  +'</a></td> <td><input type="text" id="msg' + nickname + '" value="' + message +'"/></td> <td><span class="button" onclick="update_resource(\'user\',\'' + nickname + '\')">update</span></td> <td><span class="button" onclick="delete_resource(\'user\',\'' + nickname + '\')">remove</span></td></tr>');

		tab.append(tr);
	});

	$('#content').append(tab);
	return false;
}	

function showUserConsumption(username){
	// Load template
	$('#content').load("user_consumption.html");

	// Add data
	alert($('#username'));
	//$('#content #username strong').html(nickname);
	$('#username strong').html(username);
	
            var params = getUrlVars();
            var prefix_url='/users/'+username+'/sensors';
            var login_param = { "l": user, "p" : password };

            $.getJSON(prefix_url+'.json', 
                login_param , 
                function(json){
                    // only for first sensor
                    sensor=json[0]["sensor_hr"];
                    var last_measure_param = { "l": user, "p" : password };
                    var last_day_measure_param = { "l": user, "p" : password, "from" : one_day_ago.toString(), "to": now.toString(), interval: 1800 };
                $.getJSON(prefix_url+'/'+sensor+'/measures.json', last_day_measure_param, function(measure) {
                    draw_graphic( measure );
                });
                $.getJSON(prefix_url+'/'+sensor+'/measures.json', last_measure_param, function(measure) {
                        var len=measure["data"].length;
                        var last=measure["data"][len-1];
                        var cons=last["consumption"]
                        var KWH_COST=0.082;
                        var HOURLY_COST_MULTI = 0.001;
                        var DAILY_COST_MULTI = 0.024;
                        var MONTHLY_COST_MULTI = 0.720;
                        $('#instantconsumptionvalue').html( cons + ' Watts' );
                        $('#instanthourlycostvalue').html( (cons * KWH_COST * HOURLY_COST_MULTI).toFixed(2) + " €");
                        $('#instantdailycostvalue').html( (cons * KWH_COST * DAILY_COST_MULTI).toFixed(2) + " €");
                        $('#instantmonthlycostvalue').html( (cons * KWH_COST * MONTHLY_COST_MULTI).toFixed(2) + " €");
                    });
            });

	return false;	
}

function showAccountsList(){
	// Load template
	$('#content').load("accounts_list.html");

	$.getJSON('/accounts.json',
		{l: user, p: password},
		function(data){
		buildAccountsList(data);
		return false;
	});
	// Add data
}

function buildAccountsList(data){
	$('#content').empty();
	$('#content').load("accounts_list.html");
	alert('ok');

	parity = 0;
        var nickname, password, message;
	$.each(data, function(k,v){
		nickname = v['nickname'];
		password = v['password'];
		message = v['status'];
		parity = (parity + 1)%2;

                tr = $('<tr class="r' + parity + '" id="line' + nickname + '"><td><input type="text" id="' + nickname + '"  value="' + nickname + '"/></td><td><input type="text" id="pw' + nickname + '"  value="' + password + '"/></td> <td><input type="text" id="msg' + nickname + '" value="' + message + '"/></td> <td><span class="button" onclick="update_resource(\'account\',\'' + nickname + '\')">update</span></td> <td><span class="button" onclick="delete_resource(\'account\', \'' + nickname + '\')">remove</span></td></tr>');

//alert(tr);
		$('#accounts').append(tr);
	});

	return false;
}

function showMenu(){
	$('#menu').empty();
	$('#menu').append('<a href="" onclick="showAccountsList();return false;">Accounts list</a>');
	$('#menu').append(' ');
	$('#menu').append('<a href="" onclick="showUsersList();return false;">Users list</a>');
	$('#menu').append(' ');
	$('#menu').append('<a href="/">Logout</a>');
}	

var num=0;

function update_resource(type, nickname) {
    base = '/' + type + 's/';
    $.post(
	base+nickname+'.json', 
	{   l: user,
	    p: password,
	    nickname: nickname, 
	    status: $("#msg"+nickname).val(),
	    _method: 'PUT'
	},
	function() {
	    var name='s'+num+'_'+nickname;
	    $("#info").prepend('<div id="'+name+'">'+nickname+' updated!</div>');
	    setTimeout(function(){$('#'+name).remove()},1500);
	    num++;
	});
}

function delete_resource(type, nickname) {
    base = '/' + type + 's/';
    $.post(
	base+nickname+'.json', 
	{   l: user,
	    p: password,
	    nickname: nickname, 
	    _method: 'DELETE'
	},
	function() {
		showList(type);
	});
}

function create_resource(type) {
            nk = $("#newnickname").val();
	    base = '/' + type + 's';
            $.post(
            base+'.json', 
            {   l: user,
                p: password,
                nickname: nk,
                status: $("#newmsg").val(),
                password: $("#newpw").val(), 
                _method: 'POST',
            },
            function() { 
                $.post(
                '/sensors.json', 
                {   l: user,
                    p: password,
                    user_id: nk,
                    sensor_hr: nk + '_1', 
                    description: 'Sensor for user:' + nk,
                    address:'address to be set',
                    _method: 'POST',
                },
                function() {
                    showList("account");
                });
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
    var datatabs=new Array();
    $.each(data["data"],function(index, value) {
	if (index) {
	    recupdate=new Date();
	    recupdate.setISO8601(value["date"]);
	    datatabs[index]=[ recupdate.getTime(), value["consumption"] ];
	}
    });
    var from=new Date();
    var to=new Date();
    from.setISO8601(data["from"]);
    to.setISO8601(data["to"]);
    $.plot($('#graph'), [ datatabs ], { xaxis: {
	    mode: "time",
	    min: from.getTime(),
	    max: to.getTime()
	},
	yaxis: { min: 0, max: 3000 } });
}

var now=new Date
var one_day_ago=new Date((new Date).getTime() - 24 * 3600000)
