// general action
function general_action( type, url, params, f_ok, f_err ) {
    $.ajax({ 
        type: type,
        url:  url,
        data: params,
        success: f_ok(data, textStatus, XMLHttpRequest), 
        error:  f_err(XMLHttpRequest,textStatus, errorThrown)
        });
}

function create(url, params, f_ok, f_err) {
    return general_action( "POST", url, params, f_ok, f_err);
}
function list(url, params, f_ok, f_err) {
    return general_action( "GET", url, params, f_ok, f_err);
}
function show(url, params, f_ok, f_err) {
    return general_action( "GET", url, params, f_ok, f_err);
}
function update(url, params, f_ok, f_err) {
    return general_action( "PUT", url, params, f_ok, f_err);
}
function rest_delete(url, params, f_ok, f_err) {
    return general_action( "DELETE", url, params, f_ok, f_err);
}
