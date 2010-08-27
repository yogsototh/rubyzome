# encoding: utf-8

# Rubyzome central file which load all submodules and subclasses
module Rubyzome
    require 'dm-core'

    # Include all rubyzome classes
    Dir["rubyzome/classes/*.rb"].each { |file| require file }
    def self.const_missing(c)
        Object.const_get(c)
    end

    # Load all rubyzome standard views
    $views = {} unless defined? $views
    Dir["rubyzome/classes/*View.rb"].each do |file| 
        next if file == "/rubyzome/views/RestView.rb"
        viewname=File.basename(file,File.extname(file))
        $views[viewname]=Rubyzome.const_get(viewname)
    end

    # Include all application specific classes
    Dir["app/models/*.rb"].each { |file| require file }
    Dir["app/controllers/*.rb"].each { |file| require file }

    # Load all application specific views
    Dir["app/views/*/*.rb"].each do |file| 
      require file 
      viewname=File.basename(file,File.extname(file))
      typename=File.basename(File.dirname(file))
       $views['/'+typename+'/'+viewname]=Kernel.const_get(viewname)
    end

    # Set Datamapper stuff
    DataMapper.setup(:default,$db_url)
    DataMapper.finalize
end
