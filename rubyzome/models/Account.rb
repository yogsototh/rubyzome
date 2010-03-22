# encoding: utf-8

module Rubyzome
    module AccountUserHelper
        class Account
            # Includes
            include DataMapper::Resource
        
            # Properties
            property :id,       Serial
            property :password, String
        
            # Associations
            belongs_to :user
        end
    end
end
