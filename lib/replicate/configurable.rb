# frozen_string_literal: true

module Replicate
  # Configuration module for Replicate client settings
  #
  # This module provides configuration management for API tokens, endpoints,
  # and other client settings. It can be included in both the main Replicate
  # module and individual Client instances.
  #
  # @example Configure the global client
  #   Replicate.configure do |config|
  #     config.api_token = 'your_token'
  #     config.webhook_url = 'https://example.com/webhook'
  #   end
  module Configurable
    attr_writer :api_endpoint_url, :dreambooth_endpoint_url

    class << self
      # List of configurable keys for Replicate client
      # @return [Array<Symbol>] Array of configuration option keys
      def keys
        @keys ||= %i[api_token api_endpoint_url dreambooth_endpoint_url webhook_url]
      end
    end

    # Configure the Replicate client using a block
    #
    # @yield [config] Yields the configuration object for setting options
    # @return [void]
    # @example Configure with API token
    #   Replicate.configure do |config|
    #     config.api_token = "your_token"
    #     config.webhook_url = "https://example.com/webhook"
    #   end
    def configure
      yield self
      validate_configuration!
    end

    # Get the API token
    #
    # @return [String, nil] The Replicate API token
    def api_token
      @api_token ||= ENV.fetch("REPLICATE_API_TOKEN", nil)
    end

    # Set the API token
    #
    # @param token [String] The Replicate API token
    # @raise [Replicate::ValidationError] If token is nil or empty
    def api_token=(token)
      raise Replicate::ValidationError, "API token cannot be nil or empty" if token.nil? || token.to_s.strip.empty?

      @api_token = token.to_s.strip
    end

    # Get the webhook URL
    #
    # @return [String, nil] The webhook URL for async notifications
    def webhook_url
      @webhook_url ||= ENV.fetch("REPLICATE_WEBHOOK_URL", nil)
    end

    # Set the webhook URL
    #
    # @param url [String, nil] The webhook URL for async notifications
    # @raise [Replicate::ValidationError] If URL is provided but invalid
    def webhook_url=(url)
      raise Replicate::ValidationError, "Invalid webhook URL format" if url && !valid_url?(url)

      @webhook_url = url
    end

    # Get the API endpoint URL
    #
    # @return [String] The API endpoint URL
    def api_endpoint_url
      @api_endpoint_url ||= ENV.fetch("REPLICATE_API_ENDPOINT_URL", "https://api.replicate.com/v1")
    end

    # Get the Dreambooth endpoint URL
    #
    # @return [String] The Dreambooth API endpoint URL
    def dreambooth_endpoint_url
      @dreambooth_endpoint_url || ENV.fetch("REPLICATE_DREAMBOOTH_ENDPOINT_URL", "https://dreambooth-api-experimental.replicate.com/v1")
    end

    private

    # Get all configuration options as a hash
    #
    # @return [Hash] Configuration options
    def options
      Replicate::Configurable.keys.to_h { |key| [key, send(key)] }
    end

    # Validate the current configuration
    #
    # @raise [Replicate::ConfigurationError] If configuration is invalid
    def validate_configuration!
      return unless api_token_required?

      return if @api_token

      suggestion = "Get your API token from https://replicate.com/account and set it with: " \
                   "Replicate.configure { |c| c.api_token = 'your_token' }"
      raise Replicate::ConfigurationError.new("API token is required", suggestion)
    end

    # Check if API token is required for current operation
    #
    # @return [Boolean] True if API token is required
    def api_token_required?
      true # Always require for now, could be made configurable later
    end

    # Validate URL format
    #
    # @param url [String] The URL to validate
    # @return [Boolean] True if URL is valid
    def valid_url?(url)
      uri = URI.parse(url)
      uri.scheme && uri.host && %w[http https].include?(uri.scheme)
    rescue URI::InvalidURIError
      false
    end
  end
end
