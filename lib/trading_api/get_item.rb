module TradingApi
  class GetItem < CallName
    attr_reader :item_id
  
    def initialize(item_id)
      @item_id = item_id
      super()
    end
  
    def custom_xml
      "<ItemID>#{@item_id}</ItemID>"
    end
  
    def final_price
      quantity_sold.zero? && Money.new(selling_status.at('CurrentPrice'))
    end
  
    def final_price_in_usd
      quantity_sold.zero? && Money.new(selling_status.at('ConvertedCurrentPrice'))
    end
  
    def current_price
      Money.new(selling_status.at('CurrentPrice'))
    end
  
    def bids_count
      selling_status.at('BidCount').text.to_i
    end
  
    def minimum_to_bid
      Money.new(selling_status.at('MinimumToBid'))
    end
  
    def title
      item.at('Title').text
    end
  
    def end_time
      listing_details.at('EndTime').text
    end
  
    def url
      url = listing_details.at('ViewItemURL').text
      return url if country == 'US'
      url.gsub('cgi.ebay.com', "cgi.ebay.#{country.downcase}")
    end
  
    def gallery_url
      "http://thumbs3.ebaystatic.com/pict/#{item_id}.jpg" # the only way to get the thumbnail size
    end
    
    def country
      item.at('Country').text
    end
  
    def site_code
      EBAY_SITES[item.at('Site').text].to_s
    end
  
    def seller_ebay_id
      item.at('Seller/UserID').text
    end
  
    private
        
    def item
      xml_response.at('Item')
    end
  
    def selling_status
      item.at('SellingStatus')
    end
  
    def listing_details
      item.at('ListingDetails')
    end
    
    def quantity_sold
      selling_status.at('QuantitySold').text.to_i
    end
  end
end