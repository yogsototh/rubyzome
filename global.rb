# Global configuration file

# write here the list of format you want your application to output
$viewsToLoad=["JSON","XML","HTML"]
$static_files_directory='/static'

# the DB URL default is an sqlite db file: datas.db 
# if the env variable DATABASE_URL is set it is the one choosen
# With this it works seemlessly with heroku
$db_url=ENV['DATABASE_URL'] || %{sqlite3:///tmp/datas.db}
