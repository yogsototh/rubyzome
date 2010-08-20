namespace "db" do
    task :std_db_action, [:action] do |t,args|
        require 'rubygems'
        require 'global_config'
        require 'dm-core'
        require 'dm-migrations'
        
        # Connect to DB 
        DataMapper.setup(:default, $db_url)
        # Include all models
        Dir["app/models/*.rb"].each { |file| require file }
        # Reset tables
        DataMapper.finalize
        if args.action == 'migrate'
            DataMapper.auto_migrate!
            puts 'migration finished'
        elsif args.action == 'upgrade'
            DataMapper.auto_upgrade!
            puts 'upgrade finished'
        else
            puts 'std_db_action [migrate|upgrade]'
        end
    end

    task :migrate do
        Rake.application.invoke_task("db:std_db_action[migrate]")
    end

    task :upgrade do
        Rake.application.invoke_task("db:std_db_action[upgrade]")
    end
end
