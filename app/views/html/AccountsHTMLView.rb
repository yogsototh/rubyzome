# encoding: utf-8

fatherClass=Rubyzome::HTMLView.dup

class AccountsHTMLView < fatherClass
    def content(object)
        @object=object
        render
    end
end
AccountsHTMLView.template=File.read('app/views/html/templates/accounts.erb')
