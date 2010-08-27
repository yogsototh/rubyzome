# encoding: utf-8

# Rubyzome central file which load all submodules and subclasses
module Rubyzome
    require 'dm-core'

    # Include all rubyzome classes
    Dir["rubyzome/classes/*.rb"].each { |file| puts file; require file }
    def self.const_missing(c)
        Object.const_get(c)
    end

    # Include all application specific classes
    Dir["app/models/*.rb"].each { |file| require file }
    Dir["app/views/*/*.rb"].each do |file| 
      require file 
      viewname=File.basename(file,File.extname(file))
      typename=File.basename(File.dirname(file))
       $views['/'+typename+'/'+viewname]=Kernel.const_get(viewname)
    end
    Dir["app/controllers/*.rb"].each { |file| require file }
    DataMapper.setup(:default,$db_url)
    DataMapper.finalize
end
