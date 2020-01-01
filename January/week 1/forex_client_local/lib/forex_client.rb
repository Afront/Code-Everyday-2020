require "forex_client/version"
require 'forex_client/api'

module ForexClient
  class Error < StandardError; end
  # Your code goes here...
  include API
  class Test
    def hey
      p 'hey!'
    end
  end
end