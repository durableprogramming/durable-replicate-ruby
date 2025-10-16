# frozen_string_literal: true

module Replicate
  module Record
    # Base class for all Replicate API record objects
    #
    # This class provides dynamic attribute access to API response data through method_missing,
    # allowing API responses to be accessed as object attributes.
    class Base
      # @return [Hash] The raw API response data
      attr_accessor :data

      # @return [Replicate::Client] The client instance used to make API calls
      attr_reader :client

      # Initializes a new record instance
      #
      # @param client [Replicate::Client] The client instance
      # @param params [Hash] The API response data
      def initialize(client, params)
        @client = client
        @data = deep_freeze(params)
      end

      private

      # Deep freeze nested data structures for immutability
      #
      # @param obj [Object] The object to freeze
      # @return [Object] The frozen object
      def deep_freeze(obj)
        case obj
        when Hash
          obj.dup.transform_values { |v| deep_freeze(v) }.freeze
        when Array
          obj.dup.map { |v| deep_freeze(v) }.freeze
        else
          begin
            obj.dup.freeze
          rescue StandardError
            obj.freeze
          end
        end
      end

      # Provides dynamic attribute access to API response data
      #
      # @param method_name [Symbol] The method name being called
      # @param args [Array] Arguments passed to the method
      # @param block [Proc] Optional block
      # @return [Object] The value from the API response data
      # @raise [NoMethodError] If the attribute doesn't exist in the data or if arguments/block are provided
      def method_missing(method_name, *args, &block)
        if args.empty? && block.nil? && data.key?(method_name.to_s)
          data[method_name.to_s]
        else
          super
        end
      end

      # Responds to methods that exist in the API response data
      #
      # @param method_name [Symbol] The method name to check
      # @param include_private [Boolean] Whether to include private methods
      # @return [Boolean] True if the method exists in data or is a standard method
      def respond_to_missing?(method_name, include_private = false)
        data.key?(method_name.to_s) || super
      end

      public

      # Returns a string representation of the record for debugging
      #
      # @return [String] A formatted string showing the class and data attributes
      def inspect
        "#<#{self.class.name}:#{object_id} @data={...}>"
      end

      # Returns a human-readable string representation
      #
      # @return [String] Same as inspect
      def to_s
        inspect
      end

      # Equality comparison based on record data
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] True if the objects have the same data
      def ==(other)
        return false unless other.is_a?(self.class)

        data == other.data
      end

      # Hash method for using records as hash keys
      #
      # @return [Integer] Hash value based on the record data
      def hash
        data.hash
      end

      # Case equality for pattern matching
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] True if the objects are equal
      def ===(other)
        self == other
      end
    end
  end
end
