# The code in this file is part of the Rubyzome framework
# Rubyzome framework belongs to Luc Juggery and Yann Esposito

# write here the list of format you want your application to output
$viewsToLoad=["JSON","XML","HTML"]
$directory_of_website='/website'

# the DB URL default is an sqlite db file: datas.db 
# if the env variable DATABASE_URL is set it is the one choosen
# With this it works seemlessly with heroku
$db_url=ENV['DATABASE_URL'] || %{sqlite3://#{Dir.pwd}/datas.db}

# ----------------------------------------------------------------
# DO NOT MODIFY AFTER THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
# ----------------------------------------------------------------
require 'rubygems'
require 'rack'
require 'rack-rewrite'
require 'rubyzome/rubyzome.rb'
use Rack::Rewrite do
    rewrite '/','/static/index.html'
end
use Rack::Static, :urls => ["/css", "/js", "/img", "/static", $directory_of_website], :root => "public"
run Rubyzome::RestfulDispatcher.new

