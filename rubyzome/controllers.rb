# encoding: utf-8

module Rubyzome
    # include Rubyzome default controllers
    Dir["rubyzome/controllers/*.rb"].each { |file| require file }

    # include Rubyzome helpers
    Dir["rubyzome/controllers/helpers/*.rb"].each { |file| require file }
end

