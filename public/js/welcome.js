function rzalert(message) {
    alert(message);
}

function go_to_new_todolist() {
    create('/todolists', 
            {},
            function(res){ 
                rzalert(res);
            }, 
            function(error){ 
                rzalert("Impossible de créer une nouvelle liste"); 
            });
}

$(document).ready(function(){ 
    $('#create_todolist_button').click(go_to_new_todolist);
});
