class Todo
        # Includes
        include DataMapper::Resource

        # Properties
        property :id,   Serial     
        property :description,  String
        property :done, Boolean, :default => false
        property :taken,Boolean, :default => false

        # Associations
        belongs_to :todolist,   :model => "Todolist"
end

