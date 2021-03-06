module Cryptoexchange::Exchanges
  module Sigen
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            false
          end
        end

        def fetch
          output = super ticker_url
          adapt_all(output)
        end

        def ticker_url
          "#{Cryptoexchange::Exchanges::Sigen::Market::API_URL}/ticker"
        end

        def adapt_all(output)
          output['data']['ticker'].map do |pair, ticker|
            base, target = pair.split("_")
            market_pair = Cryptoexchange::Models::MarketPair.new(
                            base: base,
                            target: target,
                            market: Sigen::Market::NAME
            )
            adapt(market_pair, ticker)
          end
        end

        def adapt(market_pair, output)
          ticker = Cryptoexchange::Models::Ticker.new
          ticker.base = market_pair.base
          ticker.target = market_pair.target
          ticker.market = Sigen::Market::NAME

          ticker.last = NumericHelper.to_d(output['last'])
          ticker.ask = NumericHelper.to_d(output['lowestAsk'])
          ticker.bid = NumericHelper.to_d(output['highestBid'])
          ticker.change = NumericHelper.to_d(output['percentChange'])
          ticker.volume = NumericHelper.to_d(output['baseVolume'])
          ticker.high = NumericHelper.to_d(output['high24hr'])
          ticker.low = NumericHelper.to_d(output['low24hr'])

          ticker.timestamp = Time.now.to_i
          ticker.payload = output
          ticker
        end
      end
    end
  end
end
