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

function signin() {
    if ( $('#remember input:checkbox').is(':checked') ) {
        $.cookie('user', user, {path:'/'});
        $.cookie('password', password, {path:'/'});
    } 
    enter_next_stage();
}

function setSpecificCss() {
    var userAgent = navigator.userAgent.toLowerCase();

    if ( /webkit/.test(userAgent) ) {
        $('head').append('<link rel="stylesheet" href="/css/webkit.css"/>');
    } else if ( /mozilla/.test(userAgent) ) {
        $('head').append('<link rel="stylesheet" href="/css/mozilla.css"/>');
    }
}

// after document loaded
$(document).ready(function(){ 
    getUserFromCookie();
    setSpecificCss();
    $('#username').click(become_active);
    $('#password').click(become_active);
    $('#username').focus(become_active);
    $('#password').focus(become_active);

    $('#username').change(function(){
        if ( $(this).val() == '' ) {
            $(this).val('User Name');
            $(this).addClass('inactive');
        } else {
            alert("before modification: " + $("#mainform").attr("action"));
            $("#mainform").attr("action","/users/"+$(this).val());
            alert("after modification: " + $("#mainform").attr("action"));
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
