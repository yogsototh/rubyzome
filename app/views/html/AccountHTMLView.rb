# encoding: utf-8
class AccountHTMLView < Rubyzome::HTMLView
    def content(object)
        if object[:html_title]
            @title="Authentification error"
            @subtitle="500"
            @content=%{Please try a new password.
                <script>top.location = "/";</script>}
        else
            @object=object
            @title="Account Setting"
            @subtitle=object[:nickname]
            @content=%{}
        end
        render
    end
end
AccountHTMLView.template=File.read('app/views/html/templates/account.erb')
