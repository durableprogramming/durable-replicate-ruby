# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Validate webhook parameter
      #
      # @param params [Hash] The prediction parameters
      # @raise [Replicate::ValidationError] If webhook is invalid
      def validate_webhook_param!(params)
        params[:webhook] = Replicate::TypeCoercion.to_string(params[:webhook])&.strip
        return if params[:webhook] && valid_url?(params[:webhook])

        raise Replicate::ValidationError, "Webhook URL must be a valid URL"
      end
    end
  end
end
