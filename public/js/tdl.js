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

function done(todoid) {
    update('/todolists/'+json['uid']+'/todos/'+todoid,
            {"done": true},
            function (res) { update_line(todoid)},
            function (res) { 
                alert("impossible to update the todo: "+todoid); });
}

function undone(todoid) {
    update('/todolists/'+json['uid']+'/todos/'+todoid,
            {"done": false},
            function (res) { update_line(todoid)},
            function (res) { 
                alert("impossible to update the todo: "+todoid); });
}

function take(todoid) {
    update('/todolists/'+json['uid']+'/todos/'+todoid,
            {"taken": true},
            function (res) { update_line(todoid)},
            function (res) { 
                alert("impossible to update the todo: "+todoid); });
}

function take(todoid) {
    update('/todolists/'+json['uid']+'/todos/'+todoid,
            {"taken": false},
            function (res) { update_line(todoid)},
            function (res) { 
                alert("impossible to update the todo: "+todoid); });
}

function update_line( id ) {
    alert('reload please');
}

$(document).ready(function(){ 
    $('#newtodo').submit( create_todo );
});
