# this module add the glue to get model object from request
module Glue
    # get todolist model object from current request
    def get_todolist(id=:todolist_id)
        todolist_id = @request[id]
        if(todolist_id.nil?) then
            raise Error, "No todolist id provided"
        end
        todolist = Todolist.first({:uid => todolist_id})
        if(todolist.nil?) then
            raise Error, "Todolist #{todolist_id} does not exist"
        end
        return todolist
    end

    # get todolist model object from current request
    def get_todo(id=:todo_id)
        todo_id = @request[id]
        if(todo_id.nil?) then
            raise Error, "No todo id provided"
        end
        todo = Todo.first({:id => todo_id})
        if(todo.nil?) then
            raise Error, "Todolist #{todo_id} does not exist"
        end
        return todo
    end
end
