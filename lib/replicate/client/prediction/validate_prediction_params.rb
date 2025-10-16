# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Validate and normalize prediction creation parameters
      #
      # @param params [Hash] The prediction parameters to validate and normalize
      # @raise [Replicate::ValidationError] If the parameters are invalid
      def validate_prediction_params!(params)
        raise Replicate::ValidationError, "Prediction parameters must be a hash" unless params.is_a?(Hash)

        validate_version_param!(params)
        validate_input_param!(params)
        validate_webhook_param!(params) if params[:webhook]
      end
    end
  end
end
