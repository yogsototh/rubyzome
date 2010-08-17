# --------------------------
# -- global configuration --

# beware the name will not match one of
# a REST resource of the application
$directory_of_website='/website'

# db configuration
$db_type='sqlite3'
$db_user=''
$db_password=''
$db_admin_user=''
$db_admin_password=''
$db_host='localhost'
$db_database='db/main.db'

constructed_db_url="#{$db_type}://"
constructed_db_url<<="#{$db_user}:"        if not $db_user.nil?
constructed_db_url<<="#{$db_password}"     if not $db_password.nil?
constructed_db_url<<="@#{$db_host}/"       if not $db_host.nil?
constructed_db_url<<="@#{$db_database}"    if not $db_database.nil?
$db_url=ENV['DATABASE_URL'] || constructed_db_url
