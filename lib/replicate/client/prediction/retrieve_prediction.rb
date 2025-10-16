# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      # Retrieves a prediction by its ID
      #
      # @param id [String] The prediction ID
      # @return [Replicate::Record::Prediction] The prediction instance
      # @raise [Replicate::ValidationError] If prediction ID is invalid
      # @raise [Replicate::APIError] If the API request fails or prediction is not found
      # @see https://replicate.com/docs/reference/http#get-prediction
      # @example Retrieve a prediction
      #   prediction = client.retrieve_prediction("abc123")
      def retrieve_prediction(id)
        validate_prediction_id!(id)
        response = api_endpoint.get("predictions/#{id}")
        Replicate::Record::Prediction.new(self, response)
      end
    end
  end
end
