class TradingApiGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def generate_config
    copy_file 'trading_api_config.yml', 'config/trading_api_config.yml'
  end
end
