# frozen_string_literal: true

module Replicate
  # HTTP endpoint agent methods
  module EndpointAgent
    # Faraday agent for making HTTP requests
    #
    # @return [Faraday::Connection] Configured Faraday connection
    def agent
      @agent ||= configure_agent
    end
  end
end
