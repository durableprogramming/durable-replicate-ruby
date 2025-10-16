# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Validate version parameter
      #
      # @param params [Hash] The prediction parameters
      # @raise [Replicate::ValidationError] If version is invalid
      def validate_version_param!(params)
        params[:version] = Replicate::TypeCoercion.to_string(params[:version])
        return if params[:version] && !params[:version].strip.empty?

        raise Replicate::ValidationError, "Version parameter must be a non-empty string"
      end
    end
  end
end
