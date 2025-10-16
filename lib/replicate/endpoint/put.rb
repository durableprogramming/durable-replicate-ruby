# frozen_string_literal: true

module Replicate
  # HTTP PUT endpoint methods
  module EndpointPut
    # Make a HTTP PUT request
    #
    # @param url [String] The path, relative to the endpoint URL
    # @param options [Hash] Body parameters for the request
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::Error] If the request fails
    def put(url, options = {})
      validate_url!(url)
      request :put, url, options.to_json
    end
  end
end
