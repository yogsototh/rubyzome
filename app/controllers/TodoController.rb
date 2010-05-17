require 'rubyzome/controllers/RestController.rb'
include Rubyzome
class TodoController < RestController

    require 'rubyzome/controllers/helpers/glue.rb'
    include ResourcesFromRequest

    def index
        get_resource("todolist").todos.all
    end

    def create
        todolist=get_resource("todolist")
        new_todo=Todo.new
        new_todo.attributes = clean_hash([:description])
        new_todo.todolist = todolist
        new_todo.save
        new_todo.attributes
    end

    def show
        get_todo.attributes
    end

    def update
        todo=get_todo
        clean_hash([:description, :done, :taken]).each do |k,v|
            todo.update( k => v )
        end
        todo.save
        { :message => 'update done successfully' }
    end

    def delete
        get_todo.destroy!
    end
end
