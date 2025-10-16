# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Coerce individual input values to appropriate types
      #
      # @param value [Object] The value to coerce
      # @return [Object] The coerced value
      def coerce_input_value(value)
        return value if [TrueClass, FalseClass, Numeric, String].any? { |type| value.is_a?(type) }

        # Try to coerce to string for unknown types
        Replicate::TypeCoercion.to_string(value) || value
      end
    end
  end
end
