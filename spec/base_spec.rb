require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestAPI < RSpreedly::Base
  attr_accessor :something
end

describe RSpreedly::Base do

  describe ".api_request" do
    it "should raise AccessDenied if a 401 is received" do
      stub_request(:put, spreedly_url("/")).to_return(:status => 401)

      lambda{
        RSpreedly::Base.api_request(:put, '/')
      }.should raise_error(RSpreedly::Error::AccessDenied)
    end
  end

  describe "attributes=" do
    before(:each) do
      @api = TestAPI.new
    end

    it "should assign attributes if they exist" do
      @api.attributes = {:something => "test"}
      @api.something.should == "test"
    end

    it "should not fail if an attribute does not exist" do
      lambda{
        @api.attributes = {:foo => true}
      }.should_not raise_error
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
      stub_request(:post, spreedly_url("/")).to_return(:status => 200)
      do_request
      @api.errors.should be_empty
    end

    it "should set one error in the error array if a string is return " do
      stub_request(:post, spreedly_url("/")).to_return(:body => fixture("error_string.txt"), :status => 422)
      failing_request
      @api.errors.should == ["Some error back from the response as a string"]
    end

    it "should set one error in the error array if an xml error with one item is returned" do
      stub_request(:post, spreedly_url("/")).to_return(:body => fixture("error.xml"), :status => 422)
      failing_request
      @api.errors.should == ["Email can't be blank"]
    end

    it "should set multiple errors in the error array if an xml error with multiple items is returned" do
      stub_request(:post, spreedly_url("/")).to_return(:body => fixture("errors.xml"), :status => 422)
      failing_request
      @api.errors.should == ["Email can't be blank", "Name can't be blank"]
    end

    it "should reset errors on each call" do
      # failing one first, which will generate some errors
      stub_request(:post, spreedly_url("/")).to_return(:body => fixture("errors.xml"), :status => 422)
      failing_request
      @api.errors.should_not be_empty

      # now a successful one should clear the errors
      stub_request(:post, spreedly_url("/")).to_return(:status => 200)
      do_request
      @api.errors.should be_empty
    end
  end
end