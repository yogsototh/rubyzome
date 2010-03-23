# encoding: utf-8

fatherClass=Rubyzome::HTMLView.dup

class UsersHTMLView < fatherClass
    def content(object)
        @title="Users"
        @object=object
        render
    end
end
UsersHTMLView.template=File.read('app/views/html/templates/users.erb')
