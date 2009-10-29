require 'logger'
require 'httparty'

require 'rspreedly/error'
require 'rspreedly/config'
require 'rspreedly/base'
require 'rspreedly/invoice'
require 'rspreedly/line_item'
require 'rspreedly/subscriber'
require 'rspreedly/subscription_plan'
require 'rspreedly/payment_method'
require 'rspreedly/complimentary_subscription'
require 'rspreedly/complimentary_time_extension'


module RSpreedly

  # a few utility methods

  # pretty much stolen from Rails
  def self.underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/\w+::/, '').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

end