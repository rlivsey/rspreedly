require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe RSpreedly::Base do

  describe "#api_request" do
    it "should raise AccessDenied if a 401 is receiver" do
      stub_http_with_code(401)
      lambda{
        RSpreedly::Base.api_request(:put, '/')
      }.should raise_error(RSpreedly::Error::AccessDenied)
    end
  end
end
