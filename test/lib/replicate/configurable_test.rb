# frozen_string_literal: true

require "test_helper"

module Replicate
  class ConfigurableTest < Minitest::Test
    def setup
      # Clear any existing configuration
      Replicate.instance_variables.each do |ivar|
        Replicate.remove_instance_variable(ivar) if Replicate::Configurable.key?(ivar.to_s[1..].to_sym)
      end
    end

    def test_configure_block_sets_attributes
      Replicate.configure do |config|
        config.api_token = "test_token"
        config.webhook_url = "https://example.com/webhook"
      end

      assert_equal "test_token", Replicate.api_token
      assert_equal "https://example.com/webhook", Replicate.webhook_url
    end

    def test_api_token_from_env
      ENV["REPLICATE_API_TOKEN"] = "env_token"
      assert_equal "env_token", Replicate.api_token
      ENV.delete("REPLICATE_API_TOKEN")
    end

    def test_webhook_url_from_env
      ENV["REPLICATE_WEBHOOK_URL"] = "https://env.example.com/webhook"
      assert_equal "https://env.example.com/webhook", Replicate.webhook_url
      ENV.delete("REPLICATE_WEBHOOK_URL")
    end

    def test_api_endpoint_url_defaults
      assert_equal "https://api.replicate.com/v1", Replicate.api_endpoint_url
    end

    def test_api_endpoint_url_from_env
      ENV["REPLICATE_API_ENDPOINT_URL"] = "https://custom.api.com/v1"
      assert_equal "https://custom.api.com/v1", Replicate.api_endpoint_url
      ENV.delete("REPLICATE_API_ENDPOINT_URL")
    end

    def test_dreambooth_endpoint_url_defaults
      assert_equal "https://dreambooth-api-experimental.replicate.com/v1", Replicate.dreambooth_endpoint_url
    end

    def test_dreambooth_endpoint_url_from_env
      ENV["REPLICATE_DREAMBOOTH_ENDPOINT_URL"] = "https://custom.dreambooth.com/v1"
      assert_equal "https://custom.dreambooth.com/v1", Replicate.dreambooth_endpoint_url
      ENV.delete("REPLICATE_DREAMBOOTH_ENDPOINT_URL")
    end

    def test_api_token_validation_nil
      assert_raises(Replicate::ValidationError) do
        Replicate.api_token = nil
      end
    end

    def test_api_token_validation_empty
      assert_raises(Replicate::ValidationError) do
        Replicate.api_token = ""
      end
    end

    def test_api_token_validation_whitespace
      assert_raises(Replicate::ValidationError) do
        Replicate.api_token = "   "
      end
    end

    def test_api_token_strips_whitespace
      Replicate.api_token = "  token  "
      assert_equal "token", Replicate.api_token
    end

    def test_webhook_url_nil_allowed
      Replicate.webhook_url = nil
      assert_nil Replicate.webhook_url
    end

    def test_webhook_url_valid
      Replicate.webhook_url = "https://example.com/webhook"
      assert_equal "https://example.com/webhook", Replicate.webhook_url
    end

    def test_webhook_url_invalid
      assert_raises(Replicate::ValidationError) do
        Replicate.webhook_url = "not-a-url"
      end
    end

    def test_webhook_url_invalid_scheme
      assert_raises(Replicate::ValidationError) do
        Replicate.webhook_url = "ftp://example.com"
      end
    end

    def test_configure_validates_configuration
      assert_raises(Replicate::ConfigurationError) do
        Replicate.configure do |config|
          # No api_token set
        end
      end
    end

    def test_configure_with_valid_token
      Replicate.configure do |config|
        config.api_token = "valid_token"
      end
      assert_equal "valid_token", Replicate.api_token
    end

    def test_keys_returns_configurable_keys
      expected_keys = %i[api_token api_endpoint_url dreambooth_endpoint_url webhook_url]
      assert_equal expected_keys, Replicate::Configurable.keys
    end

    def test_options_returns_hash_of_config
      Replicate.configure do |config|
        config.api_token = "test"
        config.webhook_url = "https://example.com"
      end

      options = Replicate.send(:options)
      assert_equal "test", options[:api_token]
      assert_equal "https://example.com", options[:webhook_url]
      assert_equal "https://api.replicate.com/v1", options[:api_endpoint_url]
      assert_equal "https://dreambooth-api-experimental.replicate.com/v1", options[:dreambooth_endpoint_url]
    end
  end
end
