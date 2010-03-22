# encoding: utf-8

fatherClass=Rubyzome::HTMLView.dup

class AccountHTMLView < fatherClass
    def content(object)
        super
    end
end
AccountHTMLView.template=File.read('rubyzome/views/html/templates/main.erb')
