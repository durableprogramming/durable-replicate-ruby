# frozen_string_literal: true

module Replicate
  # HTTP HEAD endpoint methods
  module EndpointHead
    # Make a HTTP HEAD request
    #
    # @param url [String] The path, relative to the endpoint URL
    # @param options [Hash] Query parameters for the request
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::Error] If the request fails
    def head(url, options = {})
      validate_url!(url)
      request :head, url, options
    end
  end
end
