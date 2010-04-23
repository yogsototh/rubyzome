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
    $(this).select();
}

function signin() {
    if ( $('#remember input:checkbox').is(':checked') ) {
        $.cookie('user', user, {path:'/'});
        $.cookie('password', password, {path:'/'});
    } 
    enter_next_stage();
}

function create_todo() {
    create('/todolists/'+json["uid"]+'/todos',
            {"description": $('#newtododescription').val()},
            function (res) {
                alert('new todo ok');
            },
            function(res) {
                alert('Todo not submited, try again please');
            });
    return false;
}

// after document loaded
$(document).ready(function(){ 
    $('input[type=text]').focus(become_active);
    $('#newtodo').submit( create_todo );
});
