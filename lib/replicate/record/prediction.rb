# frozen_string_literal: true

module Replicate
  module Record
    # Represents a prediction job on Replicate
    #
    # Predictions are asynchronous jobs that run models with specific inputs.
    # They have various statuses and can be monitored, cancelled, or refetched.
    #
    # @see https://replicate.com/docs/reference/http#predictions.get
    class Prediction < Base
      include Mixins::Refreshable
      include Mixins::Statusable
      # Refetches the prediction data from the API
      #
      # Updates the prediction status and data with the latest information from Replicate.
      #
      # @return [Replicate::Record::Prediction] Returns self for method chaining
      # @raise [Replicate::Error] If the API request fails
      # @example Refetch prediction status
      #   prediction.refetch
      #   puts prediction.status # Updated status
      def refetch
        @data = client.retrieve_prediction(id).data
        self
      end

      # Cancels the prediction if it's still running
      #
      # @return [Replicate::Record::Prediction] Returns self for method chaining
      # @raise [Replicate::Error] If the cancellation fails
      # @example Cancel a running prediction
      #   prediction.cancel
      def cancel
        @data = client.cancel_prediction(id).data
        self
      end

      # Checks if the prediction has finished (success, failure, or cancellation)
      #
      # Checks if the prediction is in the starting phase
      #
      # @return [Boolean] True if status is "starting"
      def starting?
        status == "starting"
      end

      # Checks if the prediction is currently processing
      #
      # @return [Boolean] True if status is "processing"
      def processing?
        status == "processing"
      end

      # Returns the prediction output if available
      #
      # @return [Array, Hash, nil] The prediction output or nil if not completed
      # @example Get prediction results
      #   if prediction.succeeded?
      #     output = prediction.output
      #     # Process the output
      #   end
      def output
        data["output"]
      end

      # Compares predictions by creation time (newer predictions are "greater")
      #
      # @param other [Replicate::Record::Prediction] The prediction to compare with
      # @return [Integer, nil] -1 if self is older, 0 if equal, 1 if newer, nil if incomparable
      def <=>(other)
        return nil unless other.is_a?(Prediction)

        created_at <=> other.created_at
      end

      # Checks if prediction was created before another prediction
      #
      # @param other [Replicate::Record::Prediction] The prediction to compare with
      # @return [Boolean] True if self was created before other
      def <(other)
        (self <=> other) == -1
      end

      # Checks if prediction was created after another prediction
      #
      # @param other [Replicate::Record::Prediction] The prediction to compare with
      # @return [Boolean] True if self was created after other
      def >(other)
        (self <=> other) == 1
      end

      # Checks if prediction was created at the same time as another prediction
      #
      # @param other [Replicate::Record::Prediction] The prediction to compare with
      # @return [Boolean] True if both predictions were created at the same time
      def ==(other)
        super && created_at == other.created_at
      end
    end
  end
end
