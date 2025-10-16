# frozen_string_literal: true

module Replicate
  # HTTP PATCH endpoint methods
  module EndpointPatch
    # Make a HTTP PATCH request
    #
    # @param url [String] The path, relative to the endpoint URL
    # @param options [Hash] Body parameters for the request
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::Error] If the request fails
    def patch(url, options = {})
      validate_url!(url)
      request :patch, url, options.to_json
    end
  end
end
