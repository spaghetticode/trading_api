module TradingApi
  
  EBAY_SITES = {
    'Germany'     => :DE,
    'Italy'       => :IT,
    'US'          => :US,
    'France'      => :FR,
    'Spain'       => :ES,
    'Netherlands' => :NL,
    'Canada'      => :CA,
    'UK'          => :GB,
    'Australia'   => :AU,
    'Austria'     => :AT
  }
  
  EBAY_SITE_CODES = {
    :AT => 16,
    :US => 0,
    :FR => 71,
    :ES => 186,
    :GB => 3,
    :DE => 77,
    :NL => 146,
    :IT => 101,
    :AU => 15,
    :CA => 2
  }
  
  class EbayError < StandardError; end
  class RequestError < EbayError; end
  class TimeoutError < EbayError; end
  
  module Config
    @@config = YAML.load_file("#{Rails.root}/config/trading_api_config.yml")[Rails.env]
    
    class << self
      %w[dev_name app_name cert_name auth_token url].each do |method|
        define_method method do
          @@config[method]
        end
      end
    end
  end
  
  class Request
    def initialize(call_name)
      @call_name = call_name
    end
      
    def headers
      {
        'X-EBAY-API-COMPATIBILITY-LEVEL' => '677',
        'X-EBAY-API-DEV-NAME'  =>  Config.dev_name,
        'X-EBAY-API-APP-NAME'  =>  Config.app_name,
        'X-EBAY-API-CERT-NAME' =>  Config.cert_name,
        'X-EBAY-API-CALL-NAME' =>  @call_name.to_s,
        'X-EBAY-API-SITEID'    =>  '0'
      }
    end
    
    def xml_payload
     %(
       <?xml version="1.0" encoding="utf-8"?>
       <#{@call_name} xmlns="urn:ebay:apis:eBLBaseComponents">
       <RequesterCredentials>
       <eBayAuthToken>#{Config.auth_token}</eBayAuthToken>
       </RequesterCredentials>
       #{@call_name.custom_xml}
       </#{@call_name}>
      )
    end
  end
  
  class Response
    attr_reader :xml_response
    
    def initialize(request)
      @request = request
      @xml_response = Nokogiri.XML(http_post).remove_namespaces!
      check_for_errors
    end
    
    private
    
    def http_post
      uri = URI.parse(Config.url)
      req = Net::HTTP.new(uri.host, uri.port)
      req.use_ssl = true 
      req.read_timeout = 10
      begin
        response = req.post(uri.request_uri, @request.xml_payload, @request.headers)
        raise RequestError, 'Problems retrieving data' unless response.is_a? Net::HTTPSuccess
      rescue Timeout::Error
        raise TimeoutError, 'Time out... remote server may be out of reach'
      end
      response.body
    end
    
    def check_for_errors
      if @xml_response.xpath('//Ack').text == 'Failure'
        message = @xml_response.xpath('//Errors/ShortMessage').text
        error_class = ('TradingApi::' + @xml_response.xpath('//Errors/ErrorClassification').text).constantize
        raise error_class, message
      end
    end
  end
  
  class CallName
    def initialize
      @request = Request.new(self)
    end
    
    def to_s
      self.class.name.split('::').last.chomp('Request')
    end
    
    def response
      @response ||= Response.new(@request)
    end
    
    def xml_response
      response.xml_response
    end
  end
  
  class Money
    attr_reader :currency_id, :amount

    def initialize(node)
      @currency_id = node['currencyID']
      @amount = node.text.to_f
    end

    def to_s
      "#{currency_id} #{format('%0.2f', amount)}"
    end
  end
end
