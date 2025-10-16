# frozen_string_literal: true

module Replicate
  module Record
    module Mixins
      # Statusable mixin for records that have status information
      #
      # This mixin provides common status checking methods for records that
      # represent asynchronous operations like predictions and training jobs.
      module Statusable
        # Checks if the operation has finished (either succeeded, failed, or canceled)
        #
        # @return [Boolean] True if the operation is no longer running
        def finished?
          succeeded? || failed? || canceled?
        end

        # Checks if the operation is currently running
        #
        # @return [Boolean] True if the operation is in progress
        def running?
          current_status == "starting" || current_status == "processing"
        end

        # Checks if the operation is in the starting phase
        #
        # @return [Boolean] True if status is "starting"
        def starting?
          current_status == "starting"
        end

        # Checks if the operation is currently processing
        #
        # @return [Boolean] True if status is "processing"
        def processing?
          current_status == "processing"
        end

        # Checks if the operation succeeded
        #
        # @return [Boolean] True if the operation completed successfully
        def succeeded?
          current_status == "succeeded"
        end

        # Checks if the operation failed
        #
        # @return [Boolean] True if the operation failed
        def failed?
          current_status == "failed"
        end

        # Checks if the operation was canceled
        #
        # @return [Boolean] True if the operation was canceled
        def canceled?
          current_status == "canceled"
        end

        # Returns a human-readable status description
        #
        # @return [String] A description of the current status
        def status_description
          case current_status
          when "starting"
            "Starting execution"
          when "processing"
            "Processing"
          when "succeeded"
            "Completed successfully"
          when "failed"
            "Failed"
          when "canceled"
            "Canceled"
          when nil
            "Unknown status: "
          else
            "Unknown status: #{current_status}"
          end
        end

        private

        # Safely get the current status, returning nil if not present
        #
        # @return [String, nil] The status value or nil
        def current_status
          data["status"]
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
