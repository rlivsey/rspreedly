require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestAPI < RSpreedly::Base; end

describe RSpreedly::Base do

  describe ".api_request" do
    it "should raise AccessDenied if a 401 is received" do
      stub_http_with_code(401)
      lambda{
        RSpreedly::Base.api_request(:put, '/')
      }.should raise_error(RSpreedly::Error::AccessDenied)
    end
  end
    
  describe "error messages" do
    
    before(:each) do
      @api = TestAPI.new
    end
  
    def do_request
      @api.api_request(:post, "/")
    end
    
    def failing_request
      lambda{
        do_request
      }.should raise_error
    end
  
    it "should not set any errors on a successful request" do
      stub_http_with_code(200)          
      do_request
      @api.errors.should be_empty
    end
    
    it "should set one error in the error array if a string is return " do
      stub_http_with_fixture("error_string.txt", 422)          
      failing_request
      @api.errors.should == ["Some error back from the response as a string"]
    end
    
    it "should set one error in the error array if an xml error with one item is returned" do
      stub_http_with_fixture("error.xml", 422)          
      failing_request
      @api.errors.should == ["Email can't be blank"]    
    end
      
    it "should set multiple errors in the error array if an xml error with multiple items is returned" do
      stub_http_with_fixture("errors.xml", 422)          
      failing_request
      @api.errors.should == ["Email can't be blank", "Name can't be blank"]    
    end      
    
    it "should reset errors on each call" do
      # failing one first, which will generate some errors
      stub_http_with_fixture("errors.xml", 422)          
      failing_request
      @api.errors.should_not be_empty
      
      # now a successful one should clear the errors
      stub_http_with_code(200)          
      do_request
      @api.errors.should be_empty
    end
  end
end