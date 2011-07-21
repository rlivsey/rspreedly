$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'webmock/rspec'
require 'rspreedly'

RSpec.configure do |config|
  config.before(:each) do
    RSpreedly::Config.reset
  end
end

def spreedly_url(path)
  "https://your-api-key:X@spreedly.com/api/v4/your-site-name#{path}"
end

def fixture(file)
  response_file = File.join(File.dirname(__FILE__), 'fixtures', file)
  File.read(response_file)
end