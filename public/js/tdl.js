function create_todo() {
    create('/todolists/'+json["uid"]+'/todos',
            {"description": $('#newtododescription').val()},
            function (res) {
                create_line( res["id"] );
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

function create_line( id ) {
    $('#todolist').prepend(
            '<tr id="task_'+id+'">'+
                '<td class="done" onclick="done('+id+')">&#x2610</td>'+
                '<td class="take" onclick="take('+id+')">take</td>'+
                '<td class="description" onclick="edit('+id+')">'+$('#newtododescription').val()+'</td>'+
            '</tr>'
            );
}
function update_line( id ) {
    show('/todolists/'+json["uid"]+'/todos/'+id,
            {},
            function (res) {
                var donepart;
                eval('res='+res);
                if (res["done"]) {
                    donepart='<td class="done" onclick="done('+id+')">&#x2610</td>';
                } else {
                    donepart='<td class="done" onclick="undone('+id+')">&#x2611</td>';
                }
                var takenpart;
                if (res["taken"]) {
                    takenpart='<td class="take" onclick="untake('+id+')">take</td>';
                } else {
                    takenpart='<td class="take" onclick="take('+id+')">free</td>';
                }
                var descriptionpart='<td class="description" onclick=edit('+id+')">'+res["description"]+'</td>';
                $('#task_'+id).html( donepart+takenpart+descriptionpart);
            },
            function(res) {
                alert('cannot update line '+ id);
            }
        );
}

$(document).ready(function(){ 
    $('#newtodo').submit( create_todo );
});
