# encoding: utf-8

# Rubyzome central file which load all submodules
# and subclasses
module Rubyzome
    require 'dm-core'

    # Include all rubyzome classes
    require 'rubyzome/lib.rb'
    require 'rubyzome/controllers.rb'
    require 'rubyzome/views.rb'
    require 'rubyzome/models.rb'

    # load the classes for the defined application
    require 'rubyzome/load_local_app.rb'

    # load the class that will handle server requests
    require 'rubyzome/RestfulDispatcher.rb'
end
