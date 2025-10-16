# frozen_string_literal: true

module Replicate
  module Record
    # Represents a specific version of a Replicate model
    #
    # Model versions contain the actual model weights and configuration needed to run predictions.
    # They can be used to create predictions with specific input parameters.
    #
    # @see https://replicate.com/docs/reference/http#models.versions.get
    class ModelVersion < Base
      # Creates a prediction using this model version
      #
      # @param input [Hash] The input parameters for the model
      # @param webhook [String, nil] Optional webhook URL for completion notifications
      # @return [Replicate::Record::Prediction] The created prediction
      # @raise [Replicate::Error] If the prediction creation fails
      # @example Create a prediction
      #   version = client.retrieve_model("stability-ai/stable-diffusion")
      #   prediction = version.predict({ prompt: "a cat wearing a hat" })
      def predict(input, webhook = nil)
        params = {}
        params[:version] = id
        params[:input] = input
        params[:webhook] = webhook if webhook
        client.create_prediction(params)
      end
    end
  end
end
