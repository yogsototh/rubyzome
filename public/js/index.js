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
	alert('about to create todolist in DB');
        create("/todolists",
	       "title='test'",
	       function(){alert('todolist created in DB')},
		function (xhr, ajaxOptions, thrownError){
                    alert(xhr.status);
		    alert(ajaxOptions);
                    alert(thrownError);
                });
    });

    // Display list of existing todolists within lists div
    // TODO
});
