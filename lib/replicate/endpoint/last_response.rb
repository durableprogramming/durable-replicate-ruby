# frozen_string_literal: true

module Replicate
  # Last response tracking methods
  module EndpointLastResponse
    # Response for last HTTP request
    #
    # @return [Faraday::Response, nil] The last response or nil if no request made
    def last_response
      @last_response if defined? @last_response
    end
  end
end
