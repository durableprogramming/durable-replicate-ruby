# frozen_string_literal: true

module Replicate
  module Record
    module Mixins
      # Refreshable mixin for records that can be refreshed from the API
      #
      # This mixin provides a standard interface for refreshing record data
      # from the API, ensuring the local instance stays in sync with the server.
      module Refreshable
        # Refreshes the record data from the API
        #
        # Updates the internal data hash with the latest information from the server.
        # This method should be implemented by classes that include this mixin.
        #
        # @return [Replicate::Record::Base] Returns self for method chaining
        # @raise [Replicate::Error] If the API request fails
        # @raise [NotImplementedError] If the method is not implemented by the including class
        def refetch
          raise NotImplementedError, "#{self.class.name} must implement #refetch"
        end

        # Checks if the record data is stale and may need refreshing
        #
        # This is a convenience method that can be overridden by subclasses
        # to implement custom staleness logic (e.g., based on timestamps).
        #
        # @return [Boolean] True if the record might be stale
        def stale?
          false # Default implementation - override in subclasses if needed
        end

        # Refreshes the record only if it's stale
        #
        # @return [Replicate::Record::Base] Returns self for method chaining
        # @see #stale?
        # @see #refetch
        def refetch_if_stale
          refetch if stale?
          self
        end
      end
    end
  end
end
