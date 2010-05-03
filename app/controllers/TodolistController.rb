require 'rubyzome/controllers/RestController.rb'
include Rubyzome
class TodolistController < RestController

    # provide get_todolist and get_todo
    require 'rubyzome/controllers/helpers/glue.rb'
    include ResourcesFromRequest

    def index
        action_not_available
    end

    def generate_random_syllab
        consomn=["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"][rand(20)]
        voyel=["a","e","i","o","u","a","o","u"][rand(5)]
        if rand(3) == 0
            voyel=voyel+["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"][rand(20)]
        end
        consomn+voyel
    end 

    def generate_random_id(n)
        (0..n).map{ generate_random_syllab }.join
    end 

    def create
        new_id=generate_random_id(4)
        while Todolist.first(:uid => new_id)
            new_id <<= generate_random_id(1)
        end
      
        new_todolist=Todolist.new( :uid => new_id )
        new_todolist.attributes = clean_hash( [:title]  )
        new_todolist.save
        return new_todolist.attributes
    end

    def show
        # todolist=get_todolist
        todolist=get_resource({ :resource_name => "todolist", 
                                :db_pkey => :uid})
        res=todolist.attributes 
        res[:todos] = todolist.todos.map{ |t| t.attributes }
        res
    end

    def update
        todolist=get_todolist
        todolist.attributes( clean_hash([:title]) )
        todolist.save
    end

    def delete
        get_todolist.destroy!
    end
end
