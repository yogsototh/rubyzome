# The code in this file is part of the Rubyzome framework
# Rubyzome framework belongs to Luc Juggery and Yann Esposito

# write here the list of format you want your application to output
$viewsToLoad=["JSON","XML","HTML"]

# Remove if you don't need Rest
require 'rubyzome/config.rb'

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
use Rack::Static, :urls => ["/css", "/js", "/img", "/static"], :root => "public"
run Rubyzome::RestfulDispatcher.new

