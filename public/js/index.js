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
    setSpecificCss();

    // Display list of existing todolists within lists div
    $.getJSON("/todolists.json", function(data){
            $.each(data, function(i,item){
		list = $('<div id="' + item.id + '" class="list">' + item.title + '</div>');
		$('#lists').append(list);

		// Add event handler on list
		// Will be used for list deletion later on
		/*
		$('#' + item.id).click(function() {
                    alert('Handler for .click() called.');
                });
                */

    // Get list of todos for the current list
    // TODO
/*
    $.getJSON("/todos.json", function(td){
        alert(1);
        alert(td);
        $.each(td, function(i,tdi){
            tdo = $('<div id="' + tdi.id + '" class="todo">' + tdi.description + '</div>');
            $('#lists').append(tdo);
        });
    });
*/
		// Add text field for new todo
	       todo = $('<form id="create_new_todo' + item.id + '"><input name="todo" type="text" id="todo_' + item.id + '" class="todo" value="New todo"/></form>');
		$('#' + item.id).append(todo);

		// Add event handle on todo
		$('#create_new_todo' + item.id).submit(function() {
		    alert("About to add a new todo to the list");
		    create("/todos",
                        {description: $('input[id="todo_' + item.id + '"]').val(), todolist_id: item.id},
                        function(){alert('todolist created in DB')},
                        function (xhr, ajaxOptions, thrownError){
                            alert(xhr.status);
                            alert(ajaxOptions);
                            alert(thrownError);
                        });
                });
	  });
    });

    $('#newlist').click(function() {
	$('#title').removeClass('inactive');
	$('#title').select();
    });

    $('#newlist').focus(function() {
	$('#title').removeClass('inactive');
	$('#title').select();
    });

    $('#title').change(function(){
        if ( $(this).val() == '' ) {
            $(this).val('New todo list');
            $(this).addClass('inactive');
        }
    });

    // Create new list in DB
    $('#create_new_list').submit(function() {
        create("/todolists",
	       {title: $('#title').val()},
	       function(){alert('todolist created in DB')},
	       function (xhr, ajaxOptions, thrownError){
                    alert(xhr.status);
		    alert(ajaxOptions);
                    alert(thrownError);
               });
    });
});
