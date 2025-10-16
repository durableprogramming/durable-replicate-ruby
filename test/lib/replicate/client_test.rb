# frozen_string_literal: true

require "test_helper"

module Replicate
  class ClientTest < Minitest::Test
    def setup
      @client = Replicate::Client.new(api_token: "test_token")
    end

    def test_initializes_with_api_token
      assert_equal "test_token", @client.api_token
    end

    def test_initializes_with_default_endpoints
      assert_equal "https://api.replicate.com/v1", @client.api_endpoint_url
      assert_equal "https://dreambooth-api-experimental.replicate.com/v1", @client.dreambooth_endpoint_url
    end

    def test_initializes_with_custom_endpoints
      client = Replicate::Client.new(
        api_token: "test",
        api_endpoint_url: "https://custom.api.com",
        dreambooth_endpoint_url: "https://custom.dreambooth.com"
      )
      assert_equal "https://custom.api.com", client.api_endpoint_url
      assert_equal "https://custom.dreambooth.com", client.dreambooth_endpoint_url
    end

    def test_api_endpoint_returns_endpoint_instance
      endpoint = @client.api_endpoint
      assert_instance_of Replicate::Endpoint, endpoint
      assert_equal @client.api_endpoint_url, endpoint.endpoint_url
      assert_equal @client.api_token, endpoint.api_token
    end

    def test_dreambooth_endpoint_returns_endpoint_instance
      endpoint = @client.dreambooth_endpoint
      assert_instance_of Replicate::Endpoint, endpoint
      assert_equal @client.dreambooth_endpoint_url, endpoint.endpoint_url
      assert_equal @client.api_token, endpoint.api_token
    end

    def test_raises_error_for_invalid_api_token
      client = Replicate::Client.new(api_token: "valid_token")

      assert_raises(Replicate::ValidationError) do
        client.api_token = ""
      end

      assert_raises(Replicate::ValidationError) do
        client.api_token = nil
      end
    end

    def test_handles_webhook_url_configuration
      client = Replicate::Client.new(api_token: "test", webhook_url: "https://example.com/webhook")
      assert_equal "https://example.com/webhook", client.webhook_url
    end

    def test_validates_webhook_url_format
      client = Replicate::Client.new(api_token: "test")

      assert_raises(Replicate::ValidationError) do
        client.webhook_url = "invalid-url"
      end
    end
  end
end
