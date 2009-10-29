require 'rubygems'
require 'spec'
require 'net-http-spy'                                                                                                                                                                                                                                                     

Net::HTTP.http_logger_options = {:verbose => true}

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspreedly'

# setup a config with dummy data
RSpreedly::Config.setup do |config|
  config.api_key        = "47d379099856610f1eb24dff41d31f8739ee0e9c"
  config.site_name      = "minutebase-test"
end

Spec::Runner.configure do |config|
  
end

def load_fixture(file)
  response_file = File.join(File.dirname(__FILE__), 'fixtures', file)
  File.read(response_file)
end

def stub_http_with_fixture(fixture, status = 200)
  stub_http_response(:body => load_fixture(fixture), :code => status)
end

def stub_http_with_code(status = 200)
  stub_http_response(:code => status)
end

def stub_http_response(opts={})
  http_response = mock(:response)
  
  http_response.stub!(:body).and_return(opts[:body] || "")
  http_response.stub!(:message).and_return("")  
  http_response.stub!(:kind_of?).and_return(true)
  http_response.stub!(:code).and_return(opts[:code] || 200)
  http_response.stub!(:to_hash).and_return({})  
  
  mock_http = mock(:net_http, :null_object => true)
  mock_http.stub!(:request).and_return(http_response)
  
  Net::HTTP.stub!(:new).and_return(mock_http)
end