function become_active() {
    $(this).removeClass('inactive');
    $(this).select();
}

// after document loaded
$(document).ready(function(){ 
    $('input[type=text]').focus(become_active);
});
