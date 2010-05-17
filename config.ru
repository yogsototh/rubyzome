# The code in this file is part of the Rubyzome framework
# Rubyzome framework belongs to Luc Juggery and Yann Esposito

require 'rubygems'
require 'rack'

require 'global_config.rb'

require 'rubyzome/rubyzome.rb'

use Rack::Static, :urls => ["/css", "/js"], :root => "public"

run Rubyzome::RestfulDispatcher.new

