# The code in this file is part of the Rubyzome framework
# Rubyzome framework belongs to Luc Juggery and Yann Esposito
# ----------------------------------------------------------------
#      DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING
# ----------------------------------------------------------------
require 'global'

require 'rubygems'
require 'rack'
require 'rack-rewrite'
require 'rubyzome/rubyzome.rb'
use Rack::Rewrite do
    rewrite '/','/static/index.html'
end
use Rack::Static, :urls => ["/css", "/js", "/img", "/static", $directory_of_website], :root => "public"
run Rubyzome::RestfulDispatcher.new

