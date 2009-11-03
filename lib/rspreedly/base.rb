module RSpreedly

  class Base
    include HTTParty
    format :xml
    base_uri "https://spreedly.com/api/v4"

    def self.api_request(type, path, options={})
      path = "/#{::RSpreedly::Config.site_name}#{path}"
      options.merge!({
        :basic_auth => {:username => RSpreedly::Config.api_key, :password => 'X'},
        :headers    => {"Content-Type" => 'application/xml'}
      })
      self.do_request(type, path, options)
    end

    def self.do_request(type, path, options)
      response  = self.send(type.to_s, path, options)      
      message   = "#{response.code}: #{response.body}"
      
      case response.code.to_i
      when 401
        raise(RSpreedly::Error::AccessDenied.new, message)        
      when 403
        raise(RSpreedly::Error::Forbidden.new, message)
      when 422
        raise(RSpreedly::Error::BadRequest.new, message)
      when 404
        raise(RSpreedly::Error::NotFound.new, message)        
      when 504
        raise(RSpreedly::Error::GatewayTimeout.new, message)                
      end      

      response
    end

    def initialize(attrs={})
      self.attributes = attrs
    end
    
    def attributes=(attrs)
      attrs.each do |k, v|
        self.send("#{k}=", v)
      end      
    end
    
    def api_request(type, path, options={})
      self.class.api_request(type, path, options)
    end

    # TODO - do this nicer
    # rather eew at the moment and hand made XML is not nice
    def to_xml(opts={})
      exclude = opts[:exclude] || []
      
      tag     = opts[:tag] || RSpreedly.underscore(self.class.to_s)
      inner   = opts[:inner]
      outer   = opts[:outer]      
      no_tag  = opts[:no_tag]
      
      xml = ""
      xml << "<#{outer}>" if outer
      xml << "<#{tag}>" unless no_tag
      xml << "<#{inner}>" if inner
      self.instance_variables.each do |var|
        name = var.gsub('@', '')
        next if exclude.include?(name.to_sym)
        value = self.instance_variable_get(var)
        if value.respond_to?(:to_xml)
          value = value.to_xml(:no_tag => (RSpreedly.underscore(value.class.to_s) == name)) 
        end
        xml << "<#{name}>#{value}</#{name}>"
      end
      xml << "</#{inner}>" if inner      
      xml << "</#{tag}>" unless no_tag
      xml << "</#{outer}>" if outer      
      xml
    end
  end
end