# frozen_string_literal: true

module Replicate
  # Main client class for interacting with the Replicate API
  #
  # The Client class provides methods for all Replicate API operations including
  # model management, prediction creation and monitoring, training jobs, and file uploads.
  # It uses a modular architecture with mixin-based functionality for better organization.
  #
  # @example Create and configure a client
  #   client = Replicate::Client.new(api_token: 'your_token')
  #
  # @example Use the global client
  #   Replicate.configure do |config|
  #     config.api_token = 'your_token'
  #   end
  #   client = Replicate.client
  #
  # @see Replicate::Configurable
  class Client
    include Replicate::Configurable

    # Include client mixins for modular functionality
    include Replicate::ClientMixins::Model
    include Replicate::ClientMixins::Prediction
    include Replicate::ClientMixins::Upload
    include Replicate::ClientMixins::Training

    # Initialize a new Replicate client
    #
    # @param options [Hash] Configuration options
    # @option options [String] :api_token API token for authentication
    # @option options [String] :api_endpoint_url Custom API endpoint URL
    # @option options [String] :dreambooth_endpoint_url Custom Dreambooth endpoint URL
    # @option options [String] :webhook_url Default webhook URL for predictions
    def initialize(options = {})
      # Use options passed in, but fall back to fresh module defaults (not cached values)
      Replicate::Configurable.each_key do |key|
        value = options.key?(key) ? options[key] : Replicate.send(key)
        instance_variable_set(:"@#{key}", value)
      end

      # Performance: Initialize cache for model lookups
      @model_cache = {}
      @version_cache = {}
    end

    # Clear cached model and version data
    #
    # @return [void]
    def clear_cache
      @model_cache.clear
      @version_cache.clear
    end

    # Get the API endpoint for Replicate API calls
    #
    # @return [Replicate::Endpoint] The configured API endpoint
    # @api private
    def api_endpoint
      @api_endpoint ||= Replicate::Endpoint.new(endpoint_url: api_endpoint_url, api_token: api_token)
    end

    # Get the Dreambooth endpoint for training API calls
    #
    # @return [Replicate::Endpoint] The configured Dreambooth endpoint
    # @api private
    def dreambooth_endpoint
      @dreambooth_endpoint ||= Replicate::Endpoint.new(endpoint_url: dreambooth_endpoint_url, api_token: api_token)
    end
  end
end
