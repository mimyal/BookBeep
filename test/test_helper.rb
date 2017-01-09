ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# For API set-up
# require 'vcr'
# require 'webmock/minitest'
#
# VCR.configure do |config|
#   config.cassette_library_dir = 'test/cassettes' # folder where casettes will be located
#   config.hook_into :webmock # tie into this other tool called webmock
#   config.default_cassette_options = {
#     :record => :new_episodes,    # record new data when we don't have it yet
#     :match_requests_on => [:method, :uri, :body] # The http method, URI and body of a request all need to match
#   }
# end

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end
