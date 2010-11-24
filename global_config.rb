# --------------------------
# -- global configuration --

# beware the name will not match one of
# a REST resource of the application
$directory_of_website='/website'

# db configuration
$db_type='sqlite3'
$db_user=nil
$db_password=nil
$db_admin_user=nil
$db_admin_password=nil
$db_host=nil
$db_database="#{Dir.pwd}/datas.db"

constructed_db_url="#{$db_type}://"
constructed_db_url<<="#{$db_user}:"        if not $db_user.nil?
constructed_db_url<<="#{$db_password}"     if not $db_password.nil?
constructed_db_url<<="@#{$db_host}/"       if not $db_host.nil?
constructed_db_url<<="@#{$db_database}"    if not $db_database.nil?
if ENV['GPENV'] == "PRODUCTION"
    $db_url="f5lxx1zz5pnorynqglhzmsp34@ec2-184-72-239-7.compute-1.amazonaws.com"
else
    $db_url=ENV['DATABASE_URL'] || constructed_db_url
end
