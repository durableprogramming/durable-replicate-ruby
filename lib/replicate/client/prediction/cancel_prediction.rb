# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      # Cancels a running prediction
      #
      # @param id [String] The prediction ID to cancel
      # @return [Replicate::Record::Prediction] The updated prediction instance
      # @raise [Replicate::ValidationError] If prediction ID is invalid
      # @raise [Replicate::APIError] If the API request fails or prediction cannot be cancelled
      # @see https://replicate.com/docs/reference/http#cancel-prediction
      # @example Cancel a prediction
      #   prediction = client.cancel_prediction("abc123")
      def cancel_prediction(id)
        validate_prediction_id!(id)
        response = api_endpoint.post("predictions/#{id}/cancel")
        Replicate::Record::Prediction.new(self, response)
      end
    end
  end
end
