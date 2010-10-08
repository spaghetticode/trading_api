require 'rubygems'
require 'rails'
require 'mocha'

# patching rails module
module Rails
  def self.root
    File.dirname(__FILE__) + '/fixtures'
  end
end
ENV["RAILS_ENV"] ||= 'test'

RSpec.configure do |config|
  config.mock_with :mocha
end

require File.dirname(__FILE__) + '/../init'
require File.dirname(__FILE__) + '/../lib/trading_api'
require File.dirname(__FILE__) + '/../lib/trading_api/get_item'

Dir['*_spec.rb'].each do |file|
  require file
end