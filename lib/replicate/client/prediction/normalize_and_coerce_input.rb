# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Prediction client mixin methods
    module Prediction
      private

      # Normalize hash keys to strings and coerce values for API compatibility
      #
      # @param hash [Hash] The hash to normalize and coerce
      # @return [Hash] Hash with string keys and coerced values
      def normalize_and_coerce_input(hash)
        hash.transform_keys(&:to_s).transform_values do |value|
          case value
          when TrueClass, FalseClass, Numeric, String
            value # Keep booleans, numbers, and strings as-is
          when Array
            value.map { |v| coerce_input_value(v) }
          when Hash
            normalize_and_coerce_input(value)
          else
            coerce_input_value(value)
          end
        end
      end
    end
  end
end
