# frozen_string_literal: true

module Replicate
  module Record
    # Represents an upload object for Dreambooth training data
    #
    # Upload objects are created to store training datasets that can be used
    # in Dreambooth model training jobs.
    #
    # @see https://replicate.com/blog/dreambooth-api
    class Upload < Base
      # Attaches a zip file to this upload
      #
      # @param path [String] The path to the zip file to upload
      # @return [Faraday::Response] The HTTP response from the upload
      # @raise [Replicate::Error] If the upload fails
      # @example Attach training data
      #   upload = client.create_upload("training_data.zip")
      #   upload.attach("/path/to/training_data.zip")
      #   puts upload.serving_url # Use this URL in training
      def attach(path)
        client.update_upload(upload_url, path)
      end

      # Returns the upload URL for attaching files
      #
      # @return [String] The upload endpoint URL
      def upload_url
        data["upload_url"]
      end

      # Returns the serving URL for accessing the uploaded data
      #
      # @return [String] The serving URL to use in training jobs
      def serving_url
        data["serving_url"]
      end
    end
  end
end
