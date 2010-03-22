# encoding: utf-8

module Rubyzome
    class RestView
        attr_accessor :head
        attr_accessor :code_return
        def init_code_return_from_object(object)
            if object.class == Hash and object.has_key?(:error)
                @code_return = object[:error]
                object.delete(:error)
            else
                @code_return = 200
            end
        end

        def httpContent(object)
            init_code_return_from_object(object)
            self.content(object)
        end
    end
end
