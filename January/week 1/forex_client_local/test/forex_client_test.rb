require "test_helper"
require "forex_client/api"
require "minitest/benchmark" if ENV["BENCH"]

class ForexClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ForexClient::VERSION
  end

  def setup
    @callstruct =  API::CallStruct.new(function = "CURRENCY_EXCHANGE_RATE", from_currency = "USD", to_currency = "TWD")
  end

  def test_to_see_if_api_can_generate_a_url_with_the_right_format
    assert @callstruct.generate_url == 'https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=TWD&apikey=' + API::API_KEY
  end

  def test_to_see_if_api_can_generate_a_json_correctly
    assert (API::get_json @callstruct).class == String 
  end

  def test_something
    API::test(function: "CURRENCY_EXCHANGE_RATE", from_currency: "USD", to_currency: "TWD")
  end
end

describe ForexClient do
  before do
    @callstruct =  API::CallStruct.new(function = "CURRENCY_EXCHANGE_RATE", from_currency = "USD", to_currency = "TWD")
  end

=begin
  describe CallStruct do
    describe "#generate_url" do
      it "generates a url" do
#        callstruct.generate_url.match 'https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=TWD&apikey=' + API::API_KEY
      end

      it "assumes API_KEY exists" do
        refute_nil API::API_KEY
      end

      it "only includes truthy values" do
        
      end

    end
    
  end
=end
  
  describe "#get_json" do
    
  end
end


describe "CallStruct Benchmark" do
  if ENV["BENCH"] then
    bench_performance_linear "CallStruct as Struct", 0.000 do |n|
      1000.times do
        API::CallStruct.new(function = "CURRENCY_EXCHANGE_RATE", from_currency = "USD", to_currency = "TWD").generate_url
      end
    end
    bench_performance_linear "CallStruct as Class", 0.000 do |n|
      1000.times do
        API::CallStructClass.new(function: "CURRENCY_EXCHANGE_RATE", from_currency: "USD", to_currency: "TWD").generate_url
      end
    end
  end
end