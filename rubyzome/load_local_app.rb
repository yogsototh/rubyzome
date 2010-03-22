# encoding: utf-8

module Rubyzome
    # TODO: centralize configuration for example: default is app/ directory (should be different)

    # TODO: use app/controllers/helpers/* instead
    # Include application custom classes (Error, Util, ...)
    require 'app/controllers/include/Helpers.rb'
    
    # Include all controllers 
    Dir["app/controllers/*.rb"].each { |file| require file }
    
    # Include all specific views (if any)
    Dir["app/views/*/*.rb"].each do |file| 
        require file 
        viewname=File.basename(file,File.extname(file))
        typename=File.basename(File.dirname(file))
        $views['/'+typename+'/'+viewname]=Kernel.const_get(viewname)
    end
    
    # Include all models
    Dir["app/models/*.rb"].each { |file| require file }
    
    # TODO: centralize datamapper configuration infos
    DataMapper.setup(:default, 'mysql://gridadmin:gridadmin@localhost/grid')
end
