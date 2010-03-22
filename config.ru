# The code in this file is part of the Rubyzome framework
# Rubyzome framework belongs to Luc Juggery and Yann Esposito

require 'rubygems'
require 'rack'

# TODO: find a better way to manage $view, may be using Rubyzome module
# n.b.: load the entire local application (/app files)
require 'rubyzome/rubyzome.rb'

# ----------------------------
# -- specific configuration --

# TODO: make a file containing central configuration only
# beware the name will not match one of
# a REST resource of the application
$directory_of_website='/website'

# TODO: one central configuration proposition
$mysql_user='rubyzome'
$mysql_password='rubyzome'
$mysql_host='mysql_rubyzome_server'
$mysql_database='rubyzome'

# -- end of specific configuration --
# -----------------------------------

run Rubyzome::RestfulDispatcher.new

