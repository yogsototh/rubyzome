require 'rubyzome/controllers/RestController.rb'
include Rubyzome
class TodoController < RestController

    # provide get_resource("todolist") and get_todo
    require 'rubyzome/controllers/helpers/glue.rb'
    include ResourcesFromRequest

    @@access={ :resource_name => "todolist", :db_key => :uid }

    def index
        keys=[ :id, :description, :done, :taken ]
        { 
            :keys =>  keys,
            :values => get_resource(@@access).todos.map { |todo| keys.map { |k| todo[k] } }
        }
    end

    def create
        todolist=get_resource( @@access )
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
