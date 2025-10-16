# frozen_string_literal: true

module Replicate
  # HTTP POST endpoint methods
  module EndpointPost
    # Make a HTTP POST request
    #
    # @param url [String] The path, relative to the endpoint URL
    # @param options [Hash] Body parameters for the request
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::Error] If the request fails
    def post(url, options = {})
      validate_url!(url)

      if multipart_request?(options)
        # Handle multipart uploads
        @last_response = agent.post(normalize_url(url)) do |req|
          req.body = options
        end
        handle_response(@last_response)
      else
        request :post, url, options.to_json
      end
    end
  end
end
