require 'benchmark'
require './lib/forex_client/api'

puts Benchmark.measure do
	10_000_00 .times do 
		API::CallStruct.new(function = "CURRENCY_EXCHANGE_RATE", from_currency = "USD", to_currency = "TWD")
	end

	10_000_00 .times do 
		API::CallStructClass.new(function: "CURRENCY_EXCHANGE_RATE", from_currency: "USD", to_currency: "TWD")
	end
end 