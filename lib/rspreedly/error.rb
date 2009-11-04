module RSpreedly
  module Error

    class Base < StandardError;    
      attr_reader :response
      
      def initialize(response=nil)
        @response  = response
      end
    end
    
    class AccessDenied    < Base;             end # 401 errors    
    class Forbidden       < Base;             end # 403 errors
    class BadRequest      < Base;             end # 422 errors
    class NotFound        < Base;             end # 404 errors
    class GatewayTimeout  < Base;             end # 504 errors  
  end  
end
