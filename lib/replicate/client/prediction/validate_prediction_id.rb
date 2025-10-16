# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Validate prediction ID format
      #
      # @param id [String] The prediction ID to validate
      # @raise [Replicate::ValidationError] If the prediction ID is invalid
      def validate_prediction_id!(id)
        return if id.is_a?(String) && !id.strip.empty?

        raise Replicate::ValidationError, "Prediction ID must be a non-empty string"
      end
    end
  end
end
