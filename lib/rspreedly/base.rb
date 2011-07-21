module RSpreedly

  class Base
    include HTTParty
    format :xml
    base_uri "https://spreedly.com/api/v4"

    attr_reader :errors

    def self.api_request(type, path, options={})
      site_name = RSpreedly::Config.site_name
      api_key = RSpreedly::Config.api_key
      path = "/#{site_name}#{path}"

      options.merge!({
        :basic_auth => {:username => api_key, :password => 'X'},
        :headers    => {"Content-Type" => 'application/xml'}
      })
      self.do_request(type, path, options)
    end

    def self.do_request(type, path, options)
      begin
        response = self.send(type.to_s, path, options)      
      rescue SocketError
        raise(RSpreedly::Error::ConnectionFailed.new, "Failed to connect to payment gateway.")
      end
      
      case response.code.to_i
      when 401
        raise(RSpreedly::Error::AccessDenied.new(response), response.body)
      when 403
        raise(RSpreedly::Error::Forbidden.new(response), response.body)
      when 422
        raise(RSpreedly::Error::BadRequest.new(response), response.body)
      when 404
        raise(RSpreedly::Error::NotFound.new(response), response.body)
      when 504
        raise(RSpreedly::Error::GatewayTimeout.new(response), response.body)
      end      

      response
    end

    def initialize(attrs={})
      @errors = []
      self.attributes = attrs
    end
    
    def attributes=(attrs)
      attrs.each do |k, v|
        self.send(:"#{k}=", v) if self.respond_to?(:"#{k}=")
      end      
    end
    
    def api_request(type, path, options={})
      @errors = []
      begin
        self.class.api_request(type, path, options)
      rescue RSpreedly::Error::Base => e
        if e.response.is_a?(Hash)
          if e.response.has_key?("errors")
            @errors = [*e.response["errors"]["error"]]
          else
            @errors = [e.response.body]
          end      
        else
          @errors = [e.message]
        end
        raise
      end
    end

    # TODO - do this nicer
    # rather eew at the moment and hand made XML is not nice
    def to_xml(opts={})
      exclude = opts[:exclude] || []
      exclude << :errors
      
      tag     = opts[:tag] || RSpreedly.underscore(self.class.to_s)
      inner   = opts[:inner]
      outer   = opts[:outer]      
      no_tag  = opts[:no_tag]
      
      xml = ""
      xml << "<#{outer}>" if outer
      xml << "<#{tag}>" unless no_tag
      xml << "<#{inner}>" if inner
      self.instance_variables.each do |var|
        name = var.to_s.gsub('@', '')
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