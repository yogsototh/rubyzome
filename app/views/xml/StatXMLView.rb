require 'nokogiri'

# Class used to send back XML 
class StatXMLView
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
        
        # Build min 
        min = Nokogiri::XML::Node.new("min",document)

        # Build max 
        max = Nokogiri::XML::Node.new("max",document)

        # Build last 
        last = Nokogiri::XML::Node.new("last",document)

        # Build average 
        average = Nokogiri::XML::Node.new("average",document)

        # Build historic 
        history = Nokogiri::XML::Node.new("history",document)

        # Loop through content 
	content.each do |item|
		if item.is_a?Hash then
			if not item[:min].nil? then
				min.content = item[:min]
			elsif not item[:max].nil? then
				max.content = item[:max]
			elsif not item[:last].nil? then
				last.content = item[:last]
			elsif not item[:average].nil? then
				average.content = item[:average]
			end
		elsif item.is_a?Array then
			item.each do |i|
				if not i.nil? and 
                    not i[:date].nil? and 
                    not i[:consumption].nil? then
					measure = build_measure(i,document)
					history.add_child(measure)
				end
			end
		end
        end

        # Add  children
        stat.add_child(min)
        stat.add_child(max)
        stat.add_child(last)
        stat.add_child(average)
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
