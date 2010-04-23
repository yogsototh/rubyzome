# encoding: utf-8

class TodolistHTMLView < Rubyzome::HTMLView
    def content(object)
        if object[:html_title]
            init_titles_from(object)
            @request={ :l => "undefined", :p => "undefined" }
            @object={ :nickname => "undefined" }
            @content<<= %{<p>Wait to return to login page</p><script>setTimeout(function(){window.location="/";},3000);</script>}
        else
            @object=object
            @title=object[:title]
            @subtitle=object[:uid]
            @content=%{}
        end
        render
    end
end
TodolistHTMLView.template=File.read('app/views/html/templates/todolist.erb')
