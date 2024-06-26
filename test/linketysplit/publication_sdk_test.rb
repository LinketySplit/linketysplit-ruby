require "test_helper"
require "uri"
require "oga"
require "json"
require "base64"

class PublicationSdkTest < Minitest::Test
  def test_create_article_purchase_link
    api_key = "2fICArLTiR5Ll3jG4jVol-erNsshmSnzMxO7AvadWKsQisNQUnMR4i9M2QaA4HO5";
    publication_sdk = Linketysplit::PublicationSdk.new(api_key)
    link = publication_sdk.createArticlePurchaseLink("https://example.com/test-article");
    refute_nil link
    jwt = URI(link).path.split("/").last
    decoded = JWT.decode jwt, api_key, true, { algorithm: "HS256" }
    assert_equal "https://example.com/test-article", decoded[0]["permalink"]

    ## with custom pricing
    link = publication_sdk.createArticlePurchaseLink("https://example.com/test-article", { 
      price: 49,
      discounts: [
        {
          quantity: 5,
          price: 45
        }
      ]

    });
    refute_nil link
    jwt = URI(link).path.split("/").last
    decoded = JWT.decode jwt, api_key, true, { algorithm: "HS256" }
    assert_equal "https://example.com/test-article", decoded[0]["permalink"]
    assert_equal 49, decoded[0]["customPricing"]["price"]
    assert_equal 45, decoded[0]["customPricing"]["discounts"][0]["price"]
    assert_nil decoded[0]["context"]
    
    ## with context
    link = publication_sdk.createArticlePurchaseLink("https://example.com/test-article", nil, "sharing");
    refute_nil link
    jwt = URI(link).path.split("/").last
    decoded = JWT.decode jwt, api_key, true, { algorithm: "HS256" }
    assert_equal "https://example.com/test-article", decoded[0]["permalink"]
    assert_nil decoded[0]["customPricing"]
    assert_equal "sharing", decoded[0]["context"]
  end

  def test_get_linkety_split_pricing_meta_tag
    pricing = { 
      price: 49,
      discounts: [
        {
          quantity: 5,
          price: 45
        }
      ]
    }
    tag = Linketysplit::PublicationSdk.getLinketySplitPricingMetaTag(pricing)
    refute_nil tag
    fragment = Oga.parse_html(tag).children.first
    assert_equal "linketysplit:pricing", fragment["property"]
    encoded = fragment["content"]
    decoded = JSON.parse(Base64.decode64(encoded))
    assert_equal 49, decoded["price"]
    assert_equal 45, decoded["discounts"][0]["price"]
  end

  def test_get_linkety_split_enabled_meta_tag
    # enabled by default
    tag = Linketysplit::PublicationSdk.getLinketySplitEnabledMetaTag()
    refute_nil tag
    fragment = Oga.parse_html(tag).children.first
    assert_equal "linketysplit:enabled", fragment["property"]
    assert_equal "true", fragment["content"]
    # passing true
    tag = Linketysplit::PublicationSdk.getLinketySplitEnabledMetaTag(true)
    refute_nil tag
    fragment = Oga.parse_html(tag).children.first
    assert_equal "linketysplit:enabled", fragment["property"]
    assert_equal "true", fragment["content"]
     # passing false
     tag = Linketysplit::PublicationSdk.getLinketySplitEnabledMetaTag(false)
     refute_nil tag
     fragment = Oga.parse_html(tag).children.first
     assert_equal "linketysplit:enabled", fragment["property"]
     assert_equal "false", fragment["content"]

  end
end