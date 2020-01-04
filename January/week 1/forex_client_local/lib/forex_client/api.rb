require 'Faraday'
require 'JSON'


module API


  raise IOError, 'ALPHA_VANTAGE_API_KEY is not set as an environmental variable' if ENV['ALPHA_VANTAGE_API_KEY'].nil?
  API_KEY = ENV['ALPHA_VANTAGE_API_KEY'].to_s
  CallStruct = Struct.new(:function, :from_currency, :to_currency, :from_symbol, :to_symbol, :interval, :outputsize, :datatype) do
    def validate_data
      parameters = {"CURRENCY_EXCHANGE_RATE"=> {:required => [function, from_currency, to_currency], :optional => []}, 
        "FX_INTRADAY"=> {:required => [function, from_symbol, to_symbol, interval], :optional => [outputsize, datatype]},  
        "FX_DAILY"=> {:required => [function, from_symbol, to_symbol], :optional => [outputsize, datatype]},
        "FX_WEEKLY"=> {:required => [function, from_symbol, to_symbol], :optional => [datatype]},
        "FX_MONTHLY"=> {:required => [function, from_symbol, to_symbol], :optional => [datatype]},
        }

      required_parameters = parameters[function][:required]
      optional_parameters = parameters[function][:optional]

      arr_err = []
      self.each_pair do |parameter, value|
        arr_err << "#{parameter} is not set" if !value && (required_parameters.include? value) #need to fix name choices soon
        arr_err << "#{parameter} should not be set for #{function}" unless (required_parameters+optional_parameters).include? value
      end

      raise ArgumentError, arr_err.join('\n') unless arr_err.empty? #fix newline

    end

    def generate_url
      validate_data
      arr = []
      self.each_pair do |parameter, value|
        arr << "#{parameter}=#{value}" if value
      end
      'https://www.alphavantage.co/query?' + arr.join('&') + '&apikey=' + API_KEY
    end
  end

  class CallStructClass
    attr_accessor :function, :from_currency, :to_currency, :from_symbol, :to_symbol, :interval, :outputsize, :datatype

    def initialize(function:, from_currency: false, to_currency: false, from_symbol: false, to_symbol: false, interval: false, outputsize: false, datatype: false)
      @function = function
      @from_currency = from_currency 
      @to_currency = to_currency
      @from_symbol = from_symbol
      @to_symbol = to_symbol
      @interval = interval
      @outputsize = outputsize
      @datatype = datatype
      validate_data
    end

    def validate_data

    end

    def generate_url
      validate_data
      arr = []
      self.instance_variables.each do |var|
        next unless value = self.instance_variable_get(var)
        arr << "#{var}=#{value}"
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


require 'benchmark'
n = 10000
Benchmark.bm(7) do |x|
  x.report("Generating struct instance and url")   {API::CallStruct.new(function = "CURRENCY_EXCHANGE_RATE", from_currency = "USD", to_currency = "TWD").generate_url}
  x.report("Generating class instance and url") {API::CallStructClass.new(function: "CURRENCY_EXCHANGE_RATE", from_currency: "USD", to_currency: "TWD").generate_url}
  x.report("Generating struct instance")   {API::CallStruct.new(function = "CURRENCY_EXCHANGE_RATE", from_currency = "USD", to_currency = "TWD")}
  x.report("Generating class instance") {API::CallStructClass.new(function: "CURRENCY_EXCHANGE_RATE", from_currency: "USD", to_currency: "TWD").generate_url}
end
