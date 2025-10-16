# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      # Creates a new prediction
      #
      # @param params [Hash] The prediction parameters including version, input, and optional webhook
      # @option params [String] :version The model version ID to use
      # @option params [Hash] :input The input parameters for the model
      # @option params [String] :webhook Optional webhook URL for completion notifications
      # @return [Replicate::Record::Prediction] The created prediction instance
      # @raise [Replicate::ValidationError] If parameters are invalid
      # @raise [Replicate::APIError] If the API request fails
      # @see https://replicate.com/docs/reference/http#create-prediction
      # @example Create a prediction
      #   prediction = client.create_prediction(
      #     version: "model-version-id",
      #     input: { prompt: "a cat" }
      #   )
      def create_prediction(params)
        validate_prediction_params!(params)
        params[:webhook] = webhook_url if webhook_url
        response = api_endpoint.post("predictions", params)
        Replicate::Record::Prediction.new(self, response)
      end
    end
  end
end
