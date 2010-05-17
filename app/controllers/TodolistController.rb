require 'rubyzome/controllers/RestController.rb'
include Rubyzome
class TodolistController < RestController

    # provide get_todolist and get_todo
    require 'rubyzome/controllers/helpers/glue.rb'
    include ResourcesFromRequest

    def index
        action_not_available
    end

    def create
        new_todolist=Todolist.new( :id => clean_hash[:id] )
        new_todolist.save
        return new_todolist.attributes
    end

    def show
        todolist=get_resource("todolist")
        res=todolist.attributes 
        res[:todos] = todolist.todos.map{ |t| t.attributes }
        res
    end

    def update
        todolist=get_resource("todolist")
        todolist.attributes( clean_hash([:title]) )
        todolist.save
    end

    def delete
        get_resource("todolist").destroy!
    end
end
