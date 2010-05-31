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

alert(data);

	 // Get number of todo lists
	 tdl_nbr = data.length

	 // Create a new row every 4 lists
	 // TODO
         $.each(data, function(i,obj){

		// Build list and add to lists
		list = buildTodolist(obj);

		// Add list to the correct row
		// TODO
                $('#lists').append(list);

		// Get todos for each list
		getListOfTodos(obj.id);

		// Add event handler on list title for renaming
		addEventHandlerOnTodolistTitle(obj.id);

		// Add text input for new todo
		buildNewTodoInput(obj.id);

		// Add event handle on todo text input
		addEventHandlerOnNewTodo(obj.id);
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

function buildTodolist(jsonObj){
    list = $('<div id="' + jsonObj.id + '" class="list"><form id="update_list_title' + jsonObj.id + '"><input type="text" class="listtitle" value="' + jsonObj.title + '"/></form></div>');
   return list;
}

// Build todo

function buildNewTodoInput(list_id){
    todo = $('<form id="create_new_todo' + list_id + '"><input name="todo" type="text" id="todo_' + list_id + '" class="newtodo" value="New todo"/></form>');
    $('#' + list_id).append(todo);

    // Add handler to make "new todo" field inactive unless clicked
    inputNewTodoField('#todo_' + list_id);
}

// Build tododescription
function buildTodoDescription(list_id, todo_id, todo_description){
    td = $('<div id="' + todo_id  + '"><form id="update_todo_description' + todo_id + '"><input type="text" id="input_todo_description' + todo_id + '" class="tododescription" value="' + todo_description + '"/></form></div>');
    $('#' + list_id).append(td);
}

// Get list of todo for a given list and append to list's div

function getListOfTodos(list_id){
    $.getJSON('/todolists/' + list_id + '/todos.json', function(todoArray){
        $.each(todoArray, function(index,todo){
	   
            // Add todo description in list
            buildTodoDescription(list_id, todo['id'], todo['description']);

            // Add event handler on todo for renaming
            addEventHandlerOnTodoDescription(todo['id']);
        });
    });
}

// Add event handler on list title

function addEventHandlerOnTodolistTitle(list_id){
    $('#update_list_title' + list_id).submit(function() {
        alert('List will be renamed');
        return false;
    });
}

// Add event handler on todo description

function addEventHandlerOnTodoDescription(todo_id){

    $('#update_todo_description' + todo_id).click(function() {
	$('#input_todo_description' + todo_id).addClass('editable');
    });

    $('#input_todo_description' + todo_id).blur(function() {
	$('#input_todo_description' + todo_id).removeClass('editable');
    });

    $('#update_todo_description' + todo_id).submit(function() {
        // Update description
	$.ajax({type: "PUT",
		url: "/todos.json",
                data: {id: todo_id, description: "test"},
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

// Add event handler on input field used to create a new Todo

function addEventHandlerOnNewTodo(list_id){
    $('#create_new_todo' + list_id).submit(function() {
        desc = $('input[id="todo_' + list_id + '"]').val();
        create("/todos.json",
               {description: desc, todolist_id: list_id},
               function(data, textStatus, XMLHttpRequest){

                   // Add todo description in list
                   buildTodoDescription(list_id, data['id'], desc);

		   // Add event handler on newly created todo
		   addEventHandlerOnTodoDescription(data['id']);

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
	var list_id;
	var title = $('#title').val();
        create("/todolists.json",
	       {title: title},
	       function(dat, textStatus, XMLHttpRequest){
		   list_id = dat['id'];
	           list = $('<div id="' + list_id + '" class="list"><form id="update_list_title' + list_id + '"><input type="text" class="listtitle" value="' + title + '"/></form></div>');
	           $('#lists').append(list);
		   // TODO: make sure list is in the correct row

		   // Add text input for new todo
		   buildNewTodoInput(list_id);

		   // Add event handle on todo text input
		   addEventHandlerOnNewTodo(list_id);

		   // Remove focus from input
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
    $(field_id).addClass('inactive');

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
}
