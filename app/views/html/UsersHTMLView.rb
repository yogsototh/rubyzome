# encoding: utf-8

fatherClass=Rubyzome::HTMLView.dup

class UsersHTMLView < fatherClass
    def content(object)
        if object.is_a?(Hash) and object[:html_title]
            init_titles_from(object)
            @request={ :l => "undefined", :p => "undefined" }
            @object={ :nickname => "undefined" }
            @content<<= %{<p>Wait to return to login page</p><script>setTimeout(function(){window.location="/";},3000);</script>}
        else
            @title="Users"
            @object=object
        end
        render
    end
end
UsersHTMLView.template=File.read('app/views/html/templates/users.erb')
