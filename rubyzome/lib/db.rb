module Rubyzome
    module DB_Conf
        require 'global_config.rb'
        def DB_Conf.dbstring_from_globalconf
            res="#{$db_type}://"
            res<<="#{$db_user}:"        if not $db_user.nil?
            res<<="#{$db_password}"     if not $db_password.nil?
            res<<="@#{$db_host}/"       if not $db_host.nil?
            res<<="@#{$db_database}"    if not $db_database.nil?
            res
        end
    end
end
