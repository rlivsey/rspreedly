module RSpreedly
  module Error
    class Base            < StandardError;  end
    class Forbidden       < Base;             end # 403 errors
    class BadRequest      < Base;             end # 422 errors
    class NotFound        < Base;             end # 404 errors
    class GatewayTimeout  < Base;             end # 504 errors  
  end  
end
