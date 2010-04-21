class Todo
        # Includes
        include DataMapper::Resource

        # Properties
        property :uid,   String, :key => true
        property :title,  String

        # Associations
        has_n :todo,   :model => "Todo"
end

