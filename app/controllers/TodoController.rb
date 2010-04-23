require 'rubyzome/controllers/RestController.rb'
include Rubyzome
class TodoController < RestController

    # provide get_todolist and get_todo
    require 'app/controllers/include/glue.rb'
    include Glue

    def index
        get_todolist.todos.all
    end

    def create
        todolist=get_todolist
        new_todo=Todo.new
        new_todo.attributes = clean_hash([:description])
        new_todo.todolist = todolist
        new_todo.save
        { :message => 'creation done' }
    end

    def show
        get_todo.attributes
    end

    def update
        todo=get_todo
        todo.attributes( clean_hash([:description, :done, :taken]) )
        todo.save
    end

    def delete
        get_todo.destroy!
    end
end
