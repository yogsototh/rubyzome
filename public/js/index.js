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
		// Build list and add to lists
		buildTodolist(item);

		// Get todos for each list
		getListOfTodos(item.id);

		// Add event handler on list title for renaming
		addEventHandlerOnTodolistTitle(item.id);

		// Add text input for new todo
		buildNewTodoInput(item.id);

		// Add event handle on todo text input
		addEventHandlerOnNewTodo(item.id);
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
    $('#lists').append(list);
}

// Build todo

function buildNewTodoInput(list_id){
    todo = $('<form id="create_new_todo' + list_id + '"><input name="todo" type="text" id="todo_' + list_id + '" class="newtodo" value="New todo"/></form>');
    $('#' + list_id).append(todo);

    // Add handler to make "new todo" field inactive unless clicked
    inputNewTodoField('#todo_' + list_id);
}

// Get list of todo for a given list and append to list's div

function getListOfTodos(list_id){
    $.getJSON('/todolists/' + list_id + '/todos.json', function(todoArray){
	var todo_id, todo_description;
        $.each(todoArray, function(k2,v2){
	    $.each(v2, function(k3,v3){
	        if(k3 == 'id' ){todo_id = v3}
		if(k3 == 'description' ){todo_description = v3}
	    });
	    td = $('<div id="' + todo_id  + '" class="todo"><form id="update_todo_description' + todo_id + '"><input type="text" class="tododescription" value="' + todo_description + '"/></form></div>');
	    $('#' + list_id).append(td);

            // Add event handler on todo for renaming
            addEventHandlerOnTodoDescription(todo_id);
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
    $('#update_todo_description' + todo_id).submit(function() {
        alert('Todo will be renamed');
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
		   var todo_id;
                   $.each(data, function(k,v){
                       if(k == 'id' ){todo_id = v}
                   });
                   td = $('<div id="' + todo_id  + '" class="todo"><form id="update_todo_description"><input type="text" class="tododescription" value="' + desc + '"/></form></div>');
                   $('#' + list_id).append(td);
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
	           $.each(dat, function(k,v){
	               if(k == 'id' ){list_id = v}
	           });

	           list = $('<div id="' + list_id + '" class="list"><form id="update_list_title' + list_id + '"><input type="text" class="listtitle" value="' + title + '"/></form></div>');
	           $('#lists').append(list);

		   // Add text input for new todo
		   buildNewTodoInput(list_id);
	       },
	       function (xhr, ajaxOptions, thrownError){
                    alert(xhr.status);
		    alert(ajaxOptions);
                    alert(thrownError);
               });
	//return false;
    });
}

// Handle click and focus for text input field
// - enable => field editable and default value selected
// - disable => field not editable and default value restored

function inputNewTodolistField(){
    $('#title').click(function() {
	$('#title').removeClass('inactive');
	$('#title').select();
    });

    $('#title').focus(function() {
	$('#title').removeClass('inactive');
	$('#title').select();
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
	$(field_id).removeClass('inactive');
	$(field_id).select();
    });

    $(field_id).focus(function() {
	$(field_id).removeClass('inactive');
	$(field_id).select();
    });

    $(field_id).blur(function() {
	$(field_id).addClass('inactive');
        $(this).val('New todo');
    });

    $(field_id).change(function(){
        if ( $(this).val() == '' ) {
            $(this).val('New todo');
            $(this).addClass('inactive');
        }
    });
}
