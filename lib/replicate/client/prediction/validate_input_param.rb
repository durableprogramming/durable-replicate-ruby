# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Validate input parameter
      #
      # @param params [Hash] The prediction parameters
      # @raise [Replicate::ValidationError] If input is invalid
      def validate_input_param!(params)
        raise Replicate::ValidationError, "Input parameter must be a hash" unless params[:input].is_a?(Hash)

        params[:input] = normalize_and_coerce_input(params[:input])
      end
    end
  end
end
