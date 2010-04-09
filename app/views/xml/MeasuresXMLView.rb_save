require 'nokogiri'

# Class used to send back XML 
class MeasuresXMLView
    # Accessors
    attr_accessor :head
    attr_accessor :env
    attr_accessor :max_value
    attr_accessor :last_value
    attr_accessor :last_date

    def initialize
        @head                 = {'Content-Type' => 'text/xml', 'charset' => 'UTF-8' }
        @max_value         = 0
        @last_value         = 0
        @last_date         = ''
    end

    # Protect XML special characters 
    def protectXML(content)
        content.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
    end

    # Create XML file with the list of items provided in content
    # Exemple:
    # <gridpocket>
    #    <data type="status"> <-- for each send, I receive a data with the type status (for the status screen)
    #       <currentValue>245</currentValue> <-- define all entries required for the screen as <name>value</name>
    #       <message>You're consuming a lot man !</message>
    #       ....
    #    </data>
    #    <data type="history" <-- this data block is regarding the data
    #          interval="day|month|year" <-- define the view day, or month or year
    #          maxValueSerie="4562" <-- the max value for the current serie below
    #          unit="w|kWh|kWm..."> <-- the unit to display
    #       <value day="23-12-2005" hour="00:00" val="243"> <!-- for each point, the date day, the hour/min and the value
    #       <value day="23-12-2005" hour="00:05" val="240">
    #       <value day="23-12-2005" hour="00:10" val="220">
    #       <value day="23-12-2005" hour="00:15" val="230">
    #    </data>
    # </gridpocket>

    def httpContent(content)
        # Buid new xml document
        document = Nokogiri::XML::Document.new

        # Add root node
        grid = Nokogiri::XML::Node.new("gridpocket",document)
        document.root = grid
        

        # Build data/status
        data_status = Nokogiri::XML::Node.new("data",document)
        data_status["type"] = "status"

        # Build data/history
        data_history = Nokogiri::XML::Node.new("data",document)
        data_history["type"] = "history"
        data_history["interval"] = "day"
        data_history["unit"] = "w"

        # Check if content is an Hash or an Array
        if content.instance_of?Hash then
                val = build_value(content,document)
                data_status.add_child(val)
        elsif content.instance_of?Array then
                content.each do |item|
                        val = build_value(item,document)
                        data_history.add_child(val)
                end
        end

        # Set max value in data/history node
        data_history["maxValueSerie"] = @max_value.to_s

        # Set last value in data/status node
        current_value = Nokogiri::XML::Node.new("currentValue",document)
        current_value.content = @last_value
        data_status.add_child(current_value)

        # Set message (linked to last value of consumption) in data/status node
        # TODO

        # Add data/status and data/history into XML document
        grid.add_child(data_status)
        grid.add_child(data_history)
        return document.to_s
    end 

   # Build item that will be inserted in the tree structure
   def build_value(item,doc)
        xml_value = Nokogiri::XML::Node.new("value",doc)

        # Get day and hour from date (YYYY-MM-DDTHH:mm:ss+xx:yy)
        d = item[:date].to_s
        d[/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/]
        day="#{$3}-#{$2}-#{$1}"
        hour="#{$4}:#{$5}"
        consumption = item[:consumption]

        xml_value["day"]  = "#{day}"
        xml_value["hour"] = "#{hour}"
        xml_value["val"]  = "#{consumption}"

        # Get max value
        @max_value = consumption.to_i if consumption.to_i > @max_value

        # Get last value
        if d > @last_date then
                @last_date = d
                @last_value = consumption
        end

        xml_value
   end
end
