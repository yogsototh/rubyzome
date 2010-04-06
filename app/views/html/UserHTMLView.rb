# encoding: utf-8

class UserHTMLView < Rubyzome::HTMLView
    def content(object)
        if object[:html_title]
            @title="Authentification error"
            @subtitle="500"
            @content=%{Please try a new password.
                <script>top.location = "/";</script>}
        else
            @title=object[:nickname]
            @subtitle=object[:status]
            @content=%{Welcome <em>#{object[:nickname]}</em>.<p>last 24 hours consumption:</p><div id="graph"></div>}
        end
        render
    end
end
UserHTMLView.template=File.read('app/views/html/templates/user.erb')
