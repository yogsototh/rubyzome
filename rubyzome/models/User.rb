# encoding: utf-8

module Rubyzome
    module AccountUserHelper
        class User
            # Includes
            include DataMapper::Resource
        
            # Properties
            property :id,       Serial
            property :nickname, String
        
            # Associations
            has 1, :account, :model => "Account"
        end
    end
end
