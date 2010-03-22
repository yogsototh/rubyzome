# encoding: utf-8

module Rubyzome
    # load all standard views
    if not defined? $views 
        $views={}
    end
    Dir["rubyzome/views/*.rb"].each do |file| 
        require file 
        if file == "/rubyzome/views/RestView.rb"
            next
        end
        viewname=File.basename(file,File.extname(file))
        $views[viewname]=Kernel.const_get(viewname)
    end
end
