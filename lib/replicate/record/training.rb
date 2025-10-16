# frozen_string_literal: true

module Replicate
  module Record
    # Represents a Dreambooth training job on Replicate
    #
    # Training jobs are asynchronous processes that fine-tune models using custom datasets.
    # They can be monitored and their status checked over time.
    #
    # @see https://replicate.com/blog/dreambooth-api
    class Training < Base
      include Mixins::Refreshable
      include Mixins::Statusable
      # Refetches the training data from the API
      #
      # Updates the training status and data with the latest information from Replicate.
      #
      # @return [Replicate::Record::Training] Returns self for method chaining
      # @raise [Replicate::Error] If the API request fails
      # @example Refetch training status
      #   training.refetch
      #   puts training.status # Updated status
      def refetch
        @data = client.retrieve_training(id).data
        self
      end

      # Returns the trained model version if training completed successfully
      #
      # @return [Replicate::Record::ModelVersion, nil] The trained model version or nil
      def version
        data["version"] ? Replicate::Record::ModelVersion.new(client, data["version"]) : nil
      end
    end
  end
end
