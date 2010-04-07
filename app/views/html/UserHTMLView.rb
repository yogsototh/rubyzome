# encoding: utf-8

class UserHTMLView < Rubyzome::HTMLView
    def content(object)
        if object[:html_title]
            init_titles_from(object)
            @request={ :l => "undefined", :p => "undefined" }
            @object={ :nickname => "undefined" }
            @content<<= %{<p>Wait to return to login page</p><script>setTimeout(function(){window.location="/";},3000);</script>}
        else
            @object=object
            @title=object[:nickname]
            @subtitle=object[:status]
            @content=%{Welcome <em>#{object[:nickname]}</em>.<p>last 24 hours consumption:</p><div id="graph">Please wait while loading data...</div>}
        end
        render
    end
end
UserHTMLView.template=File.read('app/views/html/templates/user.erb')
