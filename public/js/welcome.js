function rzalert(message) {
    alert(message);
}

function go_to_new_todolist() {
    create('/todolist', 
            {},
            function(res){ 
                window.location = res["url"]; 
            }, 
            function(error){ 
                rzalert("Impossible de créer une nouvelle liste"); 
            });
}

$(document).ready(function(){ 
    $('#create_todolist_button').click(go_to_new_todolist);
});
