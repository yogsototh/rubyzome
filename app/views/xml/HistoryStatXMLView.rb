require 'nokogiri'

# Class used to send back XML 
class HistoryStatXMLView
    # Accessors
    attr_accessor :head
    attr_accessor :env

    def initialize
        @head                 = {'Content-Type' => 'text/xml', 'charset' => 'UTF-8' }
    end

    # Protect XML special characters 
    def protectXML(content)
        content.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
    end

    def httpContent(content)
        # Buid new xml document
        document = Nokogiri::XML::Document.new

        # Add root node
        stat = Nokogiri::XML::Node.new("stats",document)
        document.root = stat
        
        # Build historic 
        history = Nokogiri::XML::Node.new("history",document)

        # Loop through content 
	content.each do |item|
		if item.is_a?Hash then
			measure = build_measure(item,document)
			history.add_child(measure)
			# TODO
		end
        end

        # Add  children
        stat.add_child(history)

        return document.to_s
    end 

   # Build measure for history purposes
   def build_measure(item,doc)
        measure = Nokogiri::XML::Node.new("measure",doc)
        measure["date"]  = "#{item[:date]}"
        measure["consumption"]  = "#{item[:consumption]}"
        measure
   end
end
