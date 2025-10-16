# frozen_string_literal: true

module Replicate
  # HTTP GET endpoint methods
  module EndpointGet
    # Make a HTTP GET request
    #
    # @param url [String] The path, relative to the endpoint URL
    # @param options [Hash] Query parameters for the request
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::Error] If the request fails
    def get(url, options = {})
      validate_url!(url)
      request :get, url, options
    end
  end
end
