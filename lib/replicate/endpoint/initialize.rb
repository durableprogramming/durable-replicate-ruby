# frozen_string_literal: true

module Replicate
  # Endpoint initialization methods
  module EndpointInitialize
    # Initialize a new endpoint
    #
    # @param endpoint_url [String] The base URL for the API endpoint
    # @param api_token [String, nil] The API token for authentication (nil for upload endpoints)
    # @param content_type [String] The content type for requests (default: "application/json")
    # @raise [ArgumentError] If endpoint_url is invalid
    def initialize(endpoint_url:, api_token:, content_type: "application/json")
      validate_endpoint_url!(endpoint_url)
      @endpoint_url = endpoint_url
      @api_token = api_token
      @content_type = content_type
    end
  end
end
