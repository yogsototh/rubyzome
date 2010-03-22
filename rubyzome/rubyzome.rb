# encoding: utf-8

module Rubyzome

    require 'dm-core'

    # Include all rubyzome classes
    require 'rubyzome/lib'
    require 'rubyzome/controllers'
    require 'rubyzome/views'
    require 'rubyzome/models'

    # load the classes for the defined application
    require 'rubyzome/load_local_app'
end
