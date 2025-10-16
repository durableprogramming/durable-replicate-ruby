# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      # Lists predictions with optional pagination
      #
      # @param cursor [String, nil] The cursor for pagination (optional)
      # @return [Hash] A hash containing "results" (array of Prediction instances) and pagination info
      # @raise [Replicate::Error] If the API request fails
      # @see https://replicate.com/docs/reference/http#get-predictions
      # @example List recent predictions
      #   predictions = client.list_predictions
      # @example List predictions with pagination
      #   predictions = client.list_predictions("cursor_value")
      def list_predictions(cursor = nil)
        params = cursor ? { cursor: cursor } : {}
        response = api_endpoint.get("predictions", params)
        response["results"].map! { |result| Replicate::Record::Prediction.new(self, result) }
        response
      end
    end
  end
end
