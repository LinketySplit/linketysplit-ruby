require "test_helper"
require "uri"
require "oga"
require "json"
require "base64"

class PublicationSdkTest < Minitest::Test
  def test_create_article_purchase_link_with_just_permalink
    api_key = "2fICArLTiR5Ll3jG4jVol-erNsshmSnzMxO7AvadWKsQisNQUnMR4i9M2QaA4HO5"
    publication_sdk = Linketysplit::PublicationSdk.new(api_key)
    link = publication_sdk.create_article_purchase_link("https://example.com/test-article")
    refute_nil link
    jwt = URI(link).path.split("/").last
    decoded = JWT.decode jwt, api_key, true, { algorithm: "HS256" }
    assert_equal "https://example.com/test-article", decoded[0]["permalink"]
  end

  def test_create_article_purchase_link_with_custom_pricing
    api_key = "2fICArLTiR5Ll3jG4jVol-erNsshmSnzMxO7AvadWKsQisNQUnMR4i9M2QaA4HO5"
    publication_sdk = Linketysplit::PublicationSdk.new(api_key)
    ## with custom pricing
    link = publication_sdk.create_article_purchase_link(
      "https://example.com/test-article",
      {
        price: 49,
        discounts: [
          {
            quantity: 5,
            price: 45
          }
        ]

      }
    )
    jwt = URI(link).path.split("/").last
    decoded = JWT.decode jwt, api_key, true, { algorithm: "HS256" }
    assert_equal "https://example.com/test-article", decoded[0]["permalink"]
    assert_equal 49, decoded[0]["customPricing"]["price"]
    assert_equal 45, decoded[0]["customPricing"]["discounts"][0]["price"]
    # assert_nil decoded[0]["context"]
  end

  def test_create_article_purchase_link_with_context
    api_key = "2fICArLTiR5Ll3jG4jVol-erNsshmSnzMxO7AvadWKsQisNQUnMR4i9M2QaA4HO5"
    publication_sdk = Linketysplit::PublicationSdk.new(api_key)
    ## with context
    link = publication_sdk.create_article_purchase_link("https://example.com/test-article", nil, "sharing")
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
    tag = Linketysplit::PublicationSdk.get_linketysplit_pricing_meta_tag(pricing)
    fragment = Oga.parse_html(tag).children.first
    assert_equal "linketysplit:pricing", fragment["property"]
    encoded = fragment["content"]
    decoded = JSON.parse(Base64.decode64(encoded))
    assert_equal 49, decoded["price"]
    assert_equal 45, decoded["discounts"][0]["price"]
  end

  def test_get_linkety_split_enabled_meta_tag_with_default
    # enabled by default
    tag = Linketysplit::PublicationSdk.get_linketysplit_enabled_meta_tag
    refute_nil tag
    fragment = Oga.parse_html(tag).children.first
    assert_equal "linketysplit:enabled", fragment["property"]
    assert_equal "true", fragment["content"]
  end

  def test_get_linkety_split_enabled_meta_tag_with_true
    # passing true
    tag = Linketysplit::PublicationSdk.get_linketysplit_enabled_meta_tag(enabled: true)
    fragment = Oga.parse_html(tag).children.first
    assert_equal "linketysplit:enabled", fragment["property"]
    assert_equal "true", fragment["content"]
  end

  def test_get_linkety_split_enabled_meta_tag_with_false
    tag = Linketysplit::PublicationSdk.get_linketysplit_enabled_meta_tag(enabled: false)
    fragment = Oga.parse_html(tag).children.first
    assert_equal "linketysplit:enabled", fragment["property"]
    assert_equal "false", fragment["content"]
  end
end
