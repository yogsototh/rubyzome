# La classe pour renvoyer les valeurs en HTML
require 'erubis'
require 'rubyzome/views/RestView.rb'
class HTMLView < RestView
    attr_accessor :request

    # make @template a class variable and not
    # a complete class hierarchy variable (as @@var are)
    class << self
        attr_accessor :template
    end
    def template
        self.class.template
    end

    def initialize
        @head = {'Content-Type' => 'text/html', 'charset' => 'UTF-8' }
    end

    # Protect special chars
    def protectHTML(content)
        content.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;')
    end

    def is_array_of_hashes?(object)
        if not object.is_a?(Array)
            return false
        end
        object.each do |x| 
            if not x.is_a?(Hash)
                return false
            end
        end
        return true
    end

    # An Array to HTML table
    def array_to_HTML(object)
        res=''
        if is_array_of_hashes?(object)
            keys = Array.new
            object.each { |x| keys |= x.keys }
            res <<= '<tr>'
            keys.each { |k| res <<= '<th>' +  html_repr(k) + '</th>' }
            res <<= '</tr>'
            parity_class=0
            object.each do |h|
                parity_class=( parity_class+1 ) % 2
                res <<= %{<tr class="r#{parity_class}">}
                keys.each do |k|
                    if h.has_key?(k)
                        res<<= %{<td>#{html_repr( h[k] )}</td>}
                    else
                        res<<= %{<td></td>}
                    end
                end
                res <<= '</tr>'
            end
        else
            object.each do |o|
                res <<= '<tr><td>' + html_repr(o) + '</td></tr>'
            end
        end
        '<table>'+res+'</table>'
    end

    # An Hash to HTML table (with two columns)
    def hash_to_HTML(object)
        res=''
        parity_class=0
        object.each do |k,v|
            parity_class=( parity_class+1 ) % 2
            res <<= %{<tr class="r#{parity_class}"><td>} + html_repr(k) + 
                '</td><td>'+ html_repr(v) +'</td></tr>'
        end
        '<table>'+res+'</table>'
    end

    # from Hash or Array to HTLM table
    def html_repr(object)
        case object
        when Array then return array_to_HTML(object)
        when Hash  then return hash_to_HTML(object)
        else return object.to_s
        end
    end

    def init_titles_from(object)
        if object.class == Hash and object.has_key?(:html_content)
           if object.has_key?(:html_title)
               @title=object[:html_title]
           else
               @title="Error"
           end
           if object.has_key?(:html_subtitle)
               @subtitle=object[:html_subtitle]
           else
               @subtitle="404"
           end
           @content=object[:html_content]
        else
            @content=html_repr(object)
            if not request.nil?
                @title=File.basename(request.path)
                @subtitile=request.path
            end
        end
    end

    def render
        Erubis::Eruby.new(template).result(binding())
    end

    # Handle content
    def content(object)
        init_titles_from(object)
        render
    end 
end

# TODO: think to create a Rubyzome contant Rubyzome::Views::TemplateDir
HTMLView.template=File.read('rubyzome/views/html/templates/main.erb')
