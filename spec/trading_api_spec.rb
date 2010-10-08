module TradingApi
  describe TradingApi do
    def xml_from(file)
      File.read("#{File.dirname(__FILE__)}/fixtures/#{file}")
    end
    
    def nokogiri_xml_from(file)  
      Nokogiri.XML(xml_from(file)).remove_namespaces!
    end
    
    it 'should have expected constants' do
      EBAY_SITES.should_not be_nil
      EBAY_SITE_CODES.should_not be_nil
    end
  
    describe Config do
      it 'should return config values' do
        %w[dev_name app_name cert_name auth_token url].each do |method|
          Config.send(method).should_not be_nil
        end
      end
    end
    
    describe Request do
      before do
        @call_name = CallName.new
        @call_name.stubs(:custom_xml).returns('')
        @request = Request.new(@call_name)
      end
      
      it { @request.headers.should be_an(Hash) }
      
      it 'should set all headers' do
        %w[ X-EBAY-API-COMPATIBILITY-LEVEL X-EBAY-API-DEV-NAME X-EBAY-API-APP-NAME
        X-EBAY-API-CERT-NAME X-EBAY-API-CALL-NAME X-EBAY-API-SITEID ].each do |header|
          @request.headers[header].should_not be_blank
        end
      end
      
      it { @request.xml_payload.should be_a(String) }
    end
    
    describe Response do
      before do
        @call_name = CallName.new
        @call_name.stubs(:custom_xml).returns('')
        @request = Request.new(@call_name)
      end
      
      context 'when no valid response is received from ebay' do
        before do
          Response.any_instance.stubs(:http_post).returns(xml_from('get_item_invalid.xml'))
        end
        
        it 'should raise an error' do
          lambda do
            @response = Response.new(@request)
          end.should raise_error(EbayError)
        end
      end
      
      context 'when a valid response is received from ebay' do
        before do
          Response.any_instance.stubs(:http_post).returns(xml_from('get_item.xml'))
        end
        
        it 'should not raise any error' do
          lambda do
            @response = Response.new(@request)
          end.should_not raise_error(EbayError)
        end
      end
    end
  end
  
  describe Money do
     before do
       node = Nokogiri.XML('<CurrentPrice currencyID="EUR">31.01</CurrentPrice>').at('CurrentPrice')
       @money = Money.new(node)
     end
   
     it { @money.currency_id.should == 'EUR' }
     it { @money.amount.should == 31.01 }
     it { @money.to_s.should == 'EUR 31.01' }    
   end
end