# encoding: utf-8

module Rubyzome
    # TODO: centralize configuration for example: default is app/ directory (should be different)

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
   
    if $db_url != ""
        DataMapper.setup(:default,$db_url)
    else
        DataMapper.setup(:default, %{#{$db_type}://#{$db_user}:#{$db_password}@#{$db_host}/#{$db_database}})
    end
end
