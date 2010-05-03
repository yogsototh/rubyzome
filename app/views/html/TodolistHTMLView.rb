# encoding: utf-8

class TodolistHTMLView < Rubyzome::HTMLView
    def content(object)
        @object=object
        @title=object[:title]
        @subtitle=object[:uid]
        @content=%{}
        render
    end
end
TodolistHTMLView.template=File.read('app/views/html/templates/todolist.erb')
TodolistHTMLView.error_template=File.read('rubyzome/views/html/templates/error.erb')
