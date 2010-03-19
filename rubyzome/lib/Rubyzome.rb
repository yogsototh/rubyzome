require 'dm-core'
Dir["rubyzome/lib/*.rb"].each { |file| require file }
Dir["rubyzome/controllers/*.rb"].each { |file| require file }

$views={}
Dir["rubyzome/views/*.rb"].each do |file| 
    require file 
    if file == "/rubyzome/views/RestView.rb"
        next
    end
    viewname=File.basename(file,File.extname(file))
    $views[viewname]=Kernel.const_get(viewname)
end

# TODO: sanitize models
# Dir["rubyzome/models/*.rb"].each { |file| require file }
# TODO: sanitize helpers
# Dir["rubyzome/helpers/*.rb"].each { |file| require file }

# ------ Load local application -----

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
