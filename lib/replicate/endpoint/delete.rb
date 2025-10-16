# frozen_string_literal: true

module Replicate
  # HTTP DELETE endpoint methods
  module EndpointDelete
    # Make a HTTP DELETE request
    #
    # @param url [String] The path, relative to the endpoint URL
    # @param options [Hash] Query parameters for the request
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::Error] If the request fails
    def delete(url, options = {})
      validate_url!(url)
      request :delete, url, options
    end
  end
end
