# encoding: utf-8

module Rubyzome
    # TODO: sanitize models to be super-class
    Dir["rubyzome/models/*.rb"].each { |file| require file }
end
