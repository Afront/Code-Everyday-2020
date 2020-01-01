require 'Faraday'
require 'JSON'

module API
	API_KEY = ENV['ALPHA_VANTAGE_API_KEY'].to_s
  CallStruct = Struct.new(:function, :from_currency, :to_currency, :from_symbol, :to_symbol, :interval, :outputsize, :datatype) do
    def validate_data

    end

    def generate_url
      arr = []
      self.each_pair do |parameter, value|
        arr << "#{parameter}=#{value}" if value
      end
      'https://www.alphavantage.co/query?' + arr.join('&') + '&apikey=' + API_KEY
    end
  end

  module_function 

  def get_json call_struct
    json_result = Faraday.get call_struct.generate_url
    json_result.body
  end

  def parse_json json_body
    p json_body.class
    p JSON.parse json_body
  end

  def test(function:, from_currency: false, to_currency: false, from_symbol: false, to_symbol: false, interval: false, outputsize: false, datatype: false)
    call = CallStruct.new(function, from_currency, to_currency, from_symbol, to_symbol, interval, outputsize, datatype)
    parse_json(get_json(call))
  end
end