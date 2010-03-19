

class UserHTMLView < HTMLView
    def content(object)
        if object.class == Hash and object.has_key?(:html_content)
            return super
        else
            @title=@request[:nickname]
            @subtitle="Your public informations"
            @content=%{Your nickname is <strong>#{@request[:user_id]}</strong><br/>Anything else is private.}
        end
        render
    end
end
UserHTMLView.template=File.read('app/views/html/templates/second.erb')
