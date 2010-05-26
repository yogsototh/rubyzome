require 'rubyzome/controllers/RestController.rb'
include Rubyzome
class TodolistController < RestController

    # provide get_todolist and get_todo
    require 'rubyzome/controllers/helpers/glue.rb'
    include ResourcesFromRequest

    def index
	todolists = Todolist.all;
	todolists.map {|x| x.attributes}
    end

    def create
        new_todolist=Todolist.new(clean_hash([:title]))
        new_todolist.save
        return new_todolist.attributes
    end

    def show
        todolist=get_resource(:model_name  => "Todolist",
			      :req_id  => "todolist_id",
			      :db_key => :id)
        res=todolist.attributes 
        res[:todos] = todolist.todos.map{ |t| t.attributes }
        res
    end

    def update
        todolist=get_resource(:model_name  => "Todolist",
			      :req_id  => "todolist_id",
			      :db_key => :id)
        todolist.attributes( clean_hash([:title]) )
        todolist.save
    end

    def delete
        todolist=get_resource(:model_name  => "Todolist",
			      :req_id  => "todolist_id",
			      :db_key => :id).destroy!
    end
end
