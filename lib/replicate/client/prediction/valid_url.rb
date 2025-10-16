# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Validate URL format
      #
      # @param url [String] The URL to validate
      # @return [Boolean] True if URL is valid
      def valid_url?(url)
        uri = URI.parse(url)
        uri.scheme && uri.host
      rescue URI::InvalidURIError
        false
      end
    end
  end
end
