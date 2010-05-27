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
		list = $('<div id="' + item.id + '" class="list"><h3>' + item.title + '</h3></div>');
		$('#lists').append(list);

                $.getJSON('/todolists/' + item.id + '/todos.json', function(todoArray){
		    $.each(todoArray, function(k2,v2){
                     $.each(v2, function(k3,v3){
			 if(k3 == 'description' ){
		             td = $('<div class="todo">' + v3 + '</div>');
		             $('#' + item.id).append(td);
			 }
		     });
		   });
                });

		// Add event handler on list
		// Will be used to rename or delete list later on
		$('#' + item.id + '> h3').click(function() {
                    alert('Trigger will be used to rename / delete list later on');
		    /* this.addClass('modify'); */
                });

		// Add text input for new todo
	        todo = $('<form id="create_new_todo' + item.id + '"><input name="todo" type="text" id="todo_' + item.id + '" class="todo" value="New todo"/></form>');
		$('#' + item.id).append(todo);

		// Add event handle on todo text input
		$('#create_new_todo' + item.id).submit(function() {
		    desc = $('input[id="todo_' + item.id + '"]').val();
		    create("/todos",
                        {description: desc, todolist_id: item.id},
                        function(data, textStatus, XMLHttpRequest){
		             td = $('<div class="todo">' + desc + '</div>');
		             $('#' + item.id).append(td);
			},
                        function (xhr, ajaxOptions, thrownError){
                            alert(xhr.status);
                            alert(ajaxOptions);
                            alert(thrownError);
                        });
			return false;
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
	       function(data, textStatus, XMLHttpRequest){
		// TODO prevent reload of the page
		// Check which id to add on newly created todolist
	           /*list = $('<div class="list"><h3>' + $('#title').val() + '</h3></div>');
		   $('#lists').append(list);
			*/
	       },
	       function (xhr, ajaxOptions, thrownError){
                    alert(xhr.status);
		    alert(ajaxOptions);
                    alert(thrownError);
               });
	// return false;
    });
});
