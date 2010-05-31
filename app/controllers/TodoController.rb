require 'rubyzome/controllers/RestController.rb'
include Rubyzome
class TodoController < RestController

    require 'rubyzome/controllers/helpers/glue.rb'
    include ResourcesFromRequest

    def index
        get_resource("todolist").todos.all.map {|x| x.attributes}
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
        todo = Todo.first(:id => @request[:todo_id])
	todo.attributes = clean_hash([:description, :done, :taken]);
        todo.save
	todo.attributes
    end

    def delete
        Todo.first(:id => @request[:todo_id]).destroy!
	{:message => 'todo deleted'}
    end
end
