# encoding: utf-8

class Todo
    # Includes
    include DataMapper::Resource

    # Properties
    property :id,           Serial
    property :description,  String, :default => "Describe what to do"
    property :done,         Boolean, :default => false

    # Associations
    belongs_to :todolist, :model => "Todolist"
end
