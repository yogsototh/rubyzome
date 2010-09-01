# encoding: utf-8

# La classe pour renvoyer les valeurs en HTML
require 'erubis'
require 'rubyzome/views/RestView.rb'
class HTMLView < RestView
        attr_accessor :request

        # make @template a class variable and not
        # a complete class hierarchy variable (as @@var are)
        class << self
            attr_accessor :template
            attr_accessor :error_template
            attr_accessor :head
        end
        def template
            self.class.template
        end
        def error_template
            self.class.error_template
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

        def index_to_HTML(object) 
            res=''
            keys = object[:keys]
            values = object[:values]
            res <<= '<tr>'
            keys.each { |k| res <<= '<th>' +  html_repr(k) + '</th>' }
            res <<= '</tr>'
            parity_class=0
            values.each do |v|
                parity_class=( parity_class+1 ) % 2
                res <<= %{<tr class="r#{parity_class}">}
                v.each do |field| 
                    res<<= %{<td>#{html_repr( field )}</td>}
                end
            end
            res <<= '</tr>'
            '<table>'+res+'</table>'
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
            when Hash  then 
                if object[:keys].nil? or object[:values].nil?
                    return hash_to_HTML(object)
                else
                    return index_to_HTML(object)
                end
            else return object.to_s
            end
        end

        def init_titles_from(object)
            @content=html_repr(object)
            if not request.nil?
                @title=File.basename(request.path)
                @subtitile=request.path
            end
        end

        def render
            Erubis::Eruby.new(template).result(binding())
        end

        def render_error
            Erubis::Eruby.new(error_template).result(binding())
        end

        # Handle content
        def content(object)
            init_titles_from(object)
            @object=object
            render
        end 

        # Handle content
        def error(object)
            @object=object
            render_error
        end 
end

    # TODO: think to create a Rubyzome contant Rubyzome::Views::TemplateDir
HTMLView.template=File.read('rubyzome/views/html/templates/main.erb')
HTMLView.error_template=File.read('rubyzome/views/html/templates/error.erb')
    # TODO: create three standard sub-template: header, content and footer. Most of time, only content should vary.
