require "typhoeus"
require "json"
require "cgi"

module Linketysplit
  class ApiEndpointFailedError < StandardError; end

  class ApiError < StandardError
    attr_reader :status_code

    def initialize(response)
      @status_code = response.code
      data = JSON.parse(response.body)
      message = data["message"].is_a?(String) ? data["message"] : "An unknown error occurred"
      super(message)
    end
  end

  class ApiEndpoints
    attr_reader :linketysplit_origin,
                :api_key

    def initialize(api_key, linketysplit_origin="https://linketysplit.com")
      @api_key = api_key
      @linketysplit_origin = linketysplit_origin
    end

    def handle_response(response)
      if response.success?
        { error: nil, data: JSON.parse(response.body) }
      elsif response.timed_out?
        { error: ApiEndpointFailedError.new("API request to #{url} timed out"), data: nil }
      elsif response.code == 0
        { error: ApiEndpointFailedError.new("API request to #{url} failed"), data: nil }
      else
        { error: ApiError.new(response), data: nil }
      end
    end

    def get(url)
      response = Typhoeus.get(
        url,
        headers: { "Authorization" => "Bearer #{api_key}", "Accept" => "application/json" }
      )
      handle_response(response)
    end

    def post(url, data)
      response = Typhoeus.post(
        url,
        headers: {
          "Authorization" => "Bearer #{api_key}",
          "Content-Type"  => "application/json",
          "Accept"        => "application/json"
        },
        body: JSON.dump(data)
      )
      handle_response(response)
    end

    def publication
      url = "#{linketysplit_origin}/api/v1/publication"
      get(url)
    end

    def article(permalink)
      encoded_permalink = CGI.escape(permalink)
      url = "#{linketysplit_origin}/api/v1/publication/article/#{encoded_permalink}"
      get(url)
    end

    def upsert_article(permalink)
      url = "#{linketysplit_origin}/api/v1/publication/article"
      data = { permalink: }
      post(url, data)
    end

    def verify_article_access(article_access_id)
      url = "#{linketysplit_origin}/api/v1/publication/verify-article-access"
      data = { articleAccessId: article_access_id }
      post(url, data)
    end
  end
end
