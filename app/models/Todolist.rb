class Todolist
        # Includes
        include DataMapper::Resource

        # Properties
        property :uid,   String, :key => true
        property :title,  String

        # Associations
        has n, :todos, :model => 'Todo'
end

