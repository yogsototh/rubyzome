var user = "";
var password = "";

function enter_next_stage() {
    return false;
}

function getUserFromCookie() {
    user = $.cookie('user');
    if (user) {
        password = $.cookie('password'); 
        $('#username').val(user).become_active();
        $('#password').val(password).become_active();
        enter_next_stage();
    }
}

function become_active() {
    $(this).removeClass('inactive');
}

function select_and_active() {
	$(this).select();
	$(this).removeClass('inactive')
}

function signin() {
    if ( $('#remember input:checkbox').is(':checked') ) {
        $.cookie('user', user, {path:'/'});
        $.cookie('password', password, {path:'/'});
    } 
    enter_next_stage();
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

	$('#signin').click( signin );
});
