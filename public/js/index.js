function setSpecificCss() {
    var userAgent = navigator.userAgent.toLowerCase();

    if ( /webkit/.test(userAgent) ) {
        $('head').append('<link rel="stylesheet" href="/css/webkit.css"/>');
    } else if ( /mozilla/.test(userAgent) ) {
        $('head').append('<link rel="stylesheet" href="/css/mozilla.css"/>');
    }
}

// Keep number of lists
var tdl_nbr = 0;

// after document loaded
$(document).ready(function(){ 
    setSpecificCss();

    // Display list of existing todolists within lists div
    $.getJSON("/todolists.json", function(data){

	 // Get number of todo lists
	 tdl_nbr = data.length

	 // Create a new row every 4 lists
	 // TODO
         $.each(data, function(i,obj){

		// Add div for cleaning 
		if(i%5 == 0){ $('#lists').append($('<div id="clean"></div>'))};

		// Build list div and add to lists div
		$('#lists').append(buildTodolist(obj.id, obj.title));

		// Get todos and add to list
		getListOfTodos(obj.id);

		// Add event handler on list title for renaming
		addEventHandlerOnTodolistTitle(obj.id);

		// Add event handler while clicking on list's delete image
		addEventHandlerOnTodolistDeleteImage(obj.id);

		// Add text input for new todo and add to list
   		$('#' + obj.id).append(buildNewTodoInput(obj.id));

		// Add event handle on todo text input
		addEventHandlerOnNewTodo(obj.id);

		// Make new todo input inactive
                inputNewTodoField('#todo_' + obj.id);
	 });
    });

    // Add event handler on new list creation
    addEventHandlerOnNewTodolist();

    // Make  "new todolist" field inactive unless clicked
    inputNewTodolistField();
});

/*********************/
/***** functions *****/
/*********************/

// Build list

function buildTodolist(id, title){
   list = $('<div id="' + id + '" class="list"><img id="img_delete_list' + id + '" src="../img/delete.gif"/><form id="update_list_title' + id + '"><input id="input_list_title' + id + '" type="text" class="listtitle" value="' + title + '"/></form></div>');
   return list;
}

// Build todo

function buildNewTodoInput(list_id){
    todo = $('<form id="create_new_todo' + list_id + '"><input name="todo" type="text" id="todo_' + list_id + '" class="newtodo" value="New todo"/></form>');
    return todo;
}

// Build todo
function buildTodo(list_id, todo_id, todo_description){
    td = $('<div id="' + todo_id  + '"><img id="img_delete_todo' + todo_id + '" src="../img/delete.gif"/><form id="update_todo_description' + todo_id + '"><input type="text" id="input_todo_description' + todo_id + '" class="tododescription" value="' + todo_description + '"/><input type="checkbox" id="input_todo_checkbox' + todo_id + '"/></form></div>');
    $('#' + list_id).append(td);
}

// Get list of todo for a given list and append to list's div

function getListOfTodos(list_id){
    $.getJSON('/todolists/' + list_id + '/todos.json', function(todoArray){
        $.each(todoArray, function(index,todo){
	   
            // Add todo description in list
            buildTodo(list_id, todo['id'], todo['description']);

            // Add event handler on todo for renaming
            addEventHandlerOnTodoDescription(todo['id']);

            // Add event handler on todo checkbox
            addEventHandlerOnTodoCheckbox(todo['id']);

	    // Add event handler on todo's delete image
	    addEventHandlerOnTodoDeleteImage(todo['id']);
        });
    });
}

// Add event handler on list's delete image

function addEventHandlerOnTodolistDeleteImage(list_id){

    $('#img_delete_list' + list_id).click(function() {
        // Update description
	$.ajax({type: "POST",
		url: '/todolists/' + list_id + '.json',
                data: {_method: "DELETE"},
                success: function(data, textStatus, XMLHttpRequest){
			$('#' + list_id).remove();
			tdl_nbr--;
                },
	        error: function (xhr, ajaxOptions, thrownError){
	           alert(xhr.status);
                   alert(ajaxOptions);
                   alert(thrownError);
	        }
         });
    });
}

// Add event handler on todo's delete image

function addEventHandlerOnTodoDeleteImage(todo_id){

    $('#img_delete_todo' + todo_id).click(function() {
        // Update description
	$.ajax({type: "POST",
		url: '/todos/' + todo_id + '.json',
                data: {_method: "DELETE"},
                success: function(data, textStatus, XMLHttpRequest){
			$('#' + todo_id).remove();
                },
	        error: function (xhr, ajaxOptions, thrownError){
	           alert(xhr.status);
                   alert(ajaxOptions);
                   alert(thrownError);
	        }
         });
    });
}

// Add event handler on list title

function addEventHandlerOnTodolistTitle(list_id){
    $('#input_list_title' + list_id).click(function() {
	$('#input_list_title' + list_id).addClass('editable');
    });

    $('#input_list_title' + list_id).blur(function() {
	$('#input_list_title' + list_id).removeClass('editable');
    });

    $('#update_list_title' + list_id).submit(function() {
        alert('List shoud be renamed (but still dont work...)');
        // Update description
	$.ajax({type: "PUT",
		url: '/todolists/' + list_id + '.json',
                data: {title: "NEW TITLE"},
                success: function(data, textStatus, XMLHttpRequest){
			alert('updated');
                },
	        error: function (xhr, ajaxOptions, thrownError){
	           alert(xhr.status);
                   alert(ajaxOptions);
                   alert(thrownError);
	        }
         });
	 $('#input_list_title' + list_id).removeClass('editable');
	 $('#input_list_title' + list_id).blur();
         return false;
    });
}

// Add event handler on todo description

function addEventHandlerOnTodoDescription(todo_id){

    $('#input_todo_description' + todo_id).click(function() {
	$('#input_todo_description' + todo_id).addClass('editable');
    });

    $('#input_todo_description' + todo_id).blur(function() {
	$('#input_todo_description' + todo_id).removeClass('editable');
    });

    $('#update_todo_description' + todo_id).submit(function() {
        // Update description
        alert('Todo shoud be renamed (but still dont work...)');
        // Update description
	$.ajax({type: "PUT",
		url: '/todos/' + todo_id + '.json',
                data: {description: "NEW DESCRIPTION"},
                success: function(data, textStatus, XMLHttpRequest){
			alert('updated');
                },
	        error: function (xhr, ajaxOptions, thrownError){
	           alert(xhr.status);
                   alert(ajaxOptions);
                   alert(thrownError);
	        }
         });
	 $('#input_todo_description' + todo_id).removeClass('editable');
	 $('#input_todo_description' + todo_id).blur();
	 return false;
    });
}

// Add event handler on todo checkbox

function addEventHandlerOnTodoCheckbox(todo_id){

    $('#input_todo_checkbox' + todo_id).change(function() {
        // Update description
        alert('Todo shoud be flagged as done in DB (but still dont work...)');
        // Update description
	$.ajax({type: "PUT",
		url: '/todos/' + todo_id + '.json',
                data: {done: true},
                success: function(data, textStatus, XMLHttpRequest){
			alert('updated');
                },
	        error: function (xhr, ajaxOptions, thrownError){
	           alert(xhr.status);
                   alert(ajaxOptions);
                   alert(thrownError);
	        }
         });
	 $('#input_todo_checkbox' + todo_id).blur();
	 return false;
    });
}

// Add event handler on input field used to create a new Todo
// Add event handler on input field used to create a new Todo

function addEventHandlerOnNewTodo(list_id){
    $('#create_new_todo' + list_id).submit(function() {
        desc = $('input[id="todo_' + list_id + '"]').val();
        create("/todos.json",
               {description: desc, todolist_id: list_id},
               function(data, textStatus, XMLHttpRequest){

                   // Add todo in list
                   buildTodo(list_id, data['id'], desc);

		   // Add event handler on newly created todo
		   addEventHandlerOnTodoDescription(data['id']);

                   // Add event handler on todo checkbox
                   addEventHandlerOnTodoCheckbox(data['id']);

		   // Add event handler on todo's delete image
		   addEventHandlerOnTodoDeleteImage(data['id']);

		   // Remove focus from input
                   $('input[id="todo_' + list_id + '"]').blur();
               },
	       function (xhr, ajaxOptions, thrownError){
	           alert(xhr.status);
                   alert(ajaxOptions);
                   alert(thrownError);
	       });
	      return false;
    });
}

// Add event handler on input field used to create a new Todolist

function addEventHandlerOnNewTodolist(){
    $('#create_new_list').submit(function() {
	var list_id ;
	var title = $('#title').val();
        create("/todolists.json",
	       {title: title},
	       function(dat, textStatus, XMLHttpRequest){
		   list_id = dat['id'];

		   // Add div for cleaning 
		   if(tdl_nbr%5 == 0){ $('#lists').append($('<div id="clean"></div>'))};
		   tdl_nbr++;

		   // Create list div and add to lists div
		   $('#lists').append(buildTodolist(list_id, title));

		   // Add text input for new todo and add to newly created list
   		   $('#' + list_id).append(buildNewTodoInput(list_id));

		   // Add event handle on todo text input
		   addEventHandlerOnNewTodo(list_id);

		   // Add event handler on list title for renaming
		   addEventHandlerOnTodolistTitle(list_id);

		   // Add event handler while clicking on list's delete image
		   addEventHandlerOnTodolistDeleteImage(list_id);

		   // Make new todo input inactive
                   inputNewTodoField('#todo_' + list_id);

		   // Remove focus from input
    		   $('#title').addClass('inactive');
		   $('#title').blur();
	       },
	       function (xhr, ajaxOptions, thrownError){
                    alert(xhr.status);
		    alert(ajaxOptions);
                    alert(thrownError);
               });
	return false;
    });
}

// Handle click and focus for text input field
// - enable => field editable and default value selected
// - disable => field not editable and default value restored

function inputNewTodolistField(){

    $('#title').click(function() {
	$(this).removeClass('inactive');
	$(this).select();
    });

    $('#title').focus(function() {
	$(this).removeClass('inactive');
	$(this).select();
    });

    $('#title').blur(function() {
	$(this).addClass('inactive');
        $(this).val('New todo list');
    });

    $('#title').change(function(){
        if ( $(this).val() == '' ) {
            $(this).val('New todo list');
            $(this).addClass('inactive');
        }
    });
}

function inputNewTodoField(field_id){

    $(field_id).click(function() {
	$(this).removeClass('inactive');
	$(this).select();
    });

    $(field_id).focus(function() {
	$(this).removeClass('inactive');
	$(this).select();
    });

    $(field_id).blur(function() {
	$(this).addClass('inactive');
        $(this).val('New todo');
    });

    $(field_id).change(function(){
        if ( $(this).val() == '' ) {
            $(this).val('New todo');
            $(this).addClass('inactive');
        }
    });

    $(field_id).addClass('inactive');
}
