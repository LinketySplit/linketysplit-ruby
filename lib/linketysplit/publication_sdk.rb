require "jwt"
require "base64"
require "json"

module Linketysplit
  class PublicationSdk
    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    # Creates a signed article purchase link with the given permalink.
    #
    # @param permalink [String] The canonical URL of the article.
    # @param customPricing [Hash, nil] Optional. Custom pricing to be applied for this purchase link,
    #   that is, for a particular user.
    #   - `:price` [Integer] The base article price in US cents.
    #   - `:discounts` [Array<Hash>] Optional. Quantity discounts.
    #     - `:quantity` [Integer] The minimum quantity at which the discount applies.
    #     - `:price` [Integer] The unit price of the article at the given quantity.
    # @param context [String, nil] Optional. Pass "sharing" if the user is sharing an article.
    # @return [String] The URL of the purchase page on LinketySplit. Show the reader a link to this URL.
    def create_article_purchase_link(permalink, custom_pricing=nil, context=nil)
      payload = {
        permalink:
      }

      payload[:customPricing] = custom_pricing if custom_pricing

      payload[:context] = context if context
      token = JWT.encode payload, @api_key, "HS256"
      "https://linketysplit.com/purchase-link/#{token}"
    end

    def self.get_linketysplit_pricing_meta_tag(article_pricing)
      content = Base64.encode64(JSON.dump(article_pricing))
      "<meta property=\"linketysplit:pricing\" content=\"#{content}\" />"
    end

    def self.get_linketysplit_enabled_meta_tag(enabled: true)
      content = enabled ? "true" : "false"
      "<meta property=\"linketysplit:enabled\" content=\"#{content}\" />"
    end
  end
end
