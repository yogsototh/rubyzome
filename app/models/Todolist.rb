# encoding: utf-8
class Todolist
    # Includes
    include DataMapper::Resource

    # Properties
   
    # the title
    property :id,  String, :key => true

    # Associations
    has n, :todos, :model => 'Todo'
end

