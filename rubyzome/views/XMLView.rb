# encoding: utf-8

module Rubyzome

    require 'nokogiri'
    require 'rubyzome/views/RestView.rb'

    # Class used to send back XML 
    class XMLView < RestView
        def initialize
            @head = {'Content-Type' => 'text/xml', 'charset' => 'UTF-8' }
        end

        # Protect XML special characters 
        def protectXML(content)
            content.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
        end

        # Create XML file with the list of items provided in content
        # Exemple:
        # <data>
        #    <item>
        #       <field_name>field_value</field_name>
        #       <field_name>field_value</field_name>
        #       ...
        #    <item>
        #       <field_name>field_value</field_name>
        #       <field_name>field_value</field_name>
        #       ...
        #    </item>
        #    ...
        # </data>
        def content(content)
            # Buid new xml document
            document = Nokogiri::XML::Document.new

            # Add root node
            data = Nokogiri::XML::Node.new("data",document)
            document.root = data
            # Check if content is an Hash or an Array
            if content.instance_of?Hash then
                xml_node = build_item(content,document)
                data.add_child(xml_node)
            elsif content.instance_of?Array then
                content.each do |item|
                    xml_node = build_item(item,document)
                    data.add_child(xml_node)
                end
            end

            return  document.to_s.gsub(/\\n/,"")
        end 

        def error(object)
            content(object)
        end

        # Build item that will be inserted in the tree structure
        def build_item(item,doc)
            xml_item = Nokogiri::XML::Node.new("item",doc)

            # Loop through each attributes of item
            item.each do |k,v|
                new_node = Nokogiri::XML::Node.new("#{k}",doc)
                new_node.content = v
                xml_item.add_child(new_node)
            end
            xml_item
        end
    end
end
