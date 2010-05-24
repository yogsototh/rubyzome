# encoding: utf-8
class Todolist
    # Includes
    include DataMapper::Resource

    # Properties
   
    # the title
    property :id,	Serial
    property :title,	String

    # Associations
    has n, :todos, :model => 'Todo'
end

