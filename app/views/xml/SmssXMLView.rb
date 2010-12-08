require 'nokogiri'

# Class used to send back XML 
class SmssXMLView
    # Accessors
    attr_accessor :head
    attr_accessor :env

    def initialize
        @head = {'Content-Type' => 'text/xml', 'charset' => 'UTF-8' }
    end

    # Protect XML special characters 
    def protectXML(content)
        content.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
    end

    # Create XML file expected by orange api
    # Exemple:
    # <?xml version="1.0" encoding="UTF-8" ?>
    # <receivesms>
    #    <status>ok</status>
    #    <response>oki guys</response>
    # </receivesms>

    def httpContent(content)
        # Buid new xml document
        document = Nokogiri::XML::Document.new

        # Add root node
        receivesms = Nokogiri::XML::Node.new("receivesms",document)
        document.root = receivesms
        
        # Build data/status
        status = Nokogiri::XML::Node.new("status",document)
        status.content = "ok"

        # Build response
        response = Nokogiri::XML::Node.new("response",document)
        response.content="test"

        # Set message (linked to last value of consumption) in data/status node
        # TODO

        # Add data/status and data/history into XML document
        receivesms.add_child(status)
        receivesms.add_child(response)
        return document.to_s
    end 
end
