# encoding: utf-8

require 'json'
require 'rubyzome/views/RestView.rb'
class JSONView < RestView
	def initialize
	    @head = {'Content-Type' => 'application/json', 'charset' => 'UTF-8' }
	end

	def content(object)
	    JSON object
	end

	def error(object)
	    content(object)
	end
end
