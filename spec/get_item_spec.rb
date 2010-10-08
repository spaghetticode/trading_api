module TradingApi
  describe GetItem do
    def nokogiri_xml_from(file)
      path = "#{File.dirname(__FILE__)}/fixtures/#{file}"
      Nokogiri.XML(File.read(path)).remove_namespaces!
    end
    
    before do
      @item_id = '14624350'
      @item = GetItem.new(@item_id)
    end
    
    before { @item.stubs(:xml_response).returns(nokogiri_xml_from('get_item.xml')) }
    
    it { @item.current_price.to_s.should == 'EUR 31.01' }
    it { @item.title.should == 'seltenes SABA Freudenstadt 8 Röhrenradio guter Zustand' }
    it { @item.custom_xml.should == "<ItemID>#{@item_id}</ItemID>" }
    it { @item.final_price.to_s.should == 'EUR 31.01' }
    it { @item.end_time.should == '2010-10-02T16:57:31.000Z' }
    it { @item.url.should == 'http://cgi.ebay.de/ws/eBayISAPI.dll?ViewItem&item=260669206334&category=113431' }
    it { @item.minimum_to_bid.to_s.should == 'EUR 31.51' }
    it { @item.bids_count.should == 12 }
    it { @item.final_price_in_usd.to_s.should == 'USD 42.63' }
    it { @item.gallery_url.should == "http://thumbs3.ebaystatic.com/pict/#{@item_id}.jpg" }
    it { @item.country.should == 'DE' }
    it { @item.site_code.should == 'DE' }
    it { @item.seller_ebay_id.should == 'ceyenneblue' }
  end
end