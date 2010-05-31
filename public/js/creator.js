function element(name, content, params) {
    res='<'+name;
    if ( params ) {
        for ( k in params) {
            if (params[k]) {
                res+=' '+k+'="'+params[k]+'"';
            }
        }
    }
    res+='>'+content+'</'+name+'>';
    return res;
}

function div(content, id, classes) {
    return element('div', content, { 'id': id, 'class': classes });
}

function form(content, id, classes) {
    return element('form', content, {'id':id, 'class':classes});
}
function textfield(value, id, classes) {
    return element('input', '', {'type': "text", 'value':value, 'id':id, 'class':classes});
}
