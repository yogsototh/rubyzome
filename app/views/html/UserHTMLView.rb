# encoding: utf-8

class UserHTMLView < Rubyzome::HTMLView
    def content(object)
        @title=object[:nickname]
        @subtitle=object[:status]
        @content=%{Welcome <em>#{object[:nickname]}</em>.<p>Your last hour consumption:</p>
        <div id="graph">Graphique</div>}
        render
    end
end
UserHTMLView.template=File.read('app/views/html/templates/user.erb')
