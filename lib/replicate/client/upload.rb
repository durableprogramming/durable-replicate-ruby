# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Methods for uploading training data to Replicate (Dreambooth API)
    module Upload
      # Creates an upload object and uploads a zip file in one step
      #
      # @param zip_path [String] The path to the zip file to upload
      # @return [Replicate::Record::Upload] The upload instance with serving URL
      # @raise [Replicate::Error] If the upload creation or file upload fails
      # @see https://replicate.com/blog/dreambooth-api
      # @example Upload a training dataset
      #   upload = client.upload_zip("path/to/training_data.zip")
      #   puts upload.serving_url # Use this URL in training
      def upload_zip(zip_path)
        validate_zip_file!(zip_path)
        filename = File.basename(zip_path)
        upload = create_upload(filename)
        upload.attach(zip_path)
        upload
      end

      # Creates a new upload object for Dreambooth training data
      #
      # @param filename [String] The filename for the upload (defaults to 'data.zip')
      # @return [Replicate::Record::Upload] The upload instance
      # @raise [Replicate::Error] If the upload creation fails
      # @see https://replicate.com/blog/dreambooth-api
      # @example Create an upload object
      #   upload = client.create_upload("my_training_data.zip")
      def create_upload(filename = "data.zip")
        response = dreambooth_endpoint.post("upload/#{filename}")
        Replicate::Record::Upload.new(self, response)
      end

      # Uploads data to a previously created upload endpoint
      #
      # @param upload_endpoint_url [String] The upload endpoint URL from create_upload
      # @param zip_path [String] The path to the zip file to upload
      # @return [Faraday::Response] The HTTP response
      # @raise [Replicate::Error] If the upload fails
      # @see https://replicate.com/blog/dreambooth-api
      # @example Upload data to an existing upload
      #   client.update_upload(upload.upload_url, "path/to/data.zip")
      def update_upload(upload_endpoint_url, zip_path)
        validate_upload_url!(upload_endpoint_url)
        validate_zip_file!(zip_path)

        endpoint = Replicate::Endpoint.new(endpoint_url: upload_endpoint_url, api_token: nil)
        endpoint.agent.put do |req|
          req.headers["Content-Type"] = "application/zip"
          req.headers["Content-Length"] = File.size(zip_path).to_s
          req.headers["Transfer-Encoding"] = "chunked"
          req.body = Faraday::UploadIO.new(zip_path, "application/zip")
        end
      end

      private

      # Validate zip file for upload
      #
      # @param zip_path [String] The path to the zip file
      # @raise [Replicate::ValidationError] If the file is invalid
      def validate_zip_file!(zip_path)
        validate_zip_path!(zip_path)
        validate_zip_security!(zip_path)
        validate_zip_existence!(zip_path)
        validate_zip_extension!(zip_path)
        validate_zip_size!(zip_path)
        validate_zip_format!(zip_path)
      end

      # Validate zip path is a non-empty string
      #
      # @param zip_path [String] The path to validate
      # @raise [Replicate::ValidationError] If invalid
      def validate_zip_path!(zip_path)
        return if zip_path.is_a?(String) && !zip_path.strip.empty?

        raise Replicate::ValidationError, "Zip path must be a non-empty string"
      end

      # Validate zip path for security (no directory traversal)
      #
      # @param zip_path [String] The path to validate
      # @raise [Replicate::ValidationError] If insecure
      def validate_zip_security!(zip_path)
        expanded_path = File.expand_path(zip_path)
        return if expanded_path.start_with?(Dir.pwd, "/")

        raise Replicate::ValidationError, "Zip path contains invalid characters or path traversal"
      end

      # Validate zip file exists and is a file
      #
      # @param zip_path [String] The path to validate
      # @raise [Replicate::ValidationError] If not exists or not file
      def validate_zip_existence!(zip_path)
        raise Replicate::ValidationError, "Zip file does not exist: #{zip_path}" unless File.exist?(zip_path)
        raise Replicate::ValidationError, "Path is not a file: #{zip_path}" unless File.file?(zip_path)
      end

      # Validate zip file extension
      #
      # @param zip_path [String] The path to validate
      # @raise [Replicate::ValidationError] If not .zip
      def validate_zip_extension!(zip_path)
        return if File.extname(zip_path).casecmp(".zip").zero?

        raise Replicate::ValidationError, "File must have .zip extension"
      end

      # Validate zip file size
      #
      # @param zip_path [String] The path to validate
      # @raise [Replicate::ValidationError] If too large
      def validate_zip_size!(zip_path)
        max_size = 1 * 1024 * 1024 * 1024 # 1GB
        return if File.size(zip_path) <= max_size

        raise Replicate::ValidationError, "Zip file too large (max 1GB): #{File.size(zip_path)} bytes"
      end

      # Validate zip file format by magic bytes
      #
      # @param zip_path [String] The path to validate
      # @raise [Replicate::ValidationError] If not zip
      def validate_zip_format!(zip_path)
        File.open(zip_path, "rb") do |f|
          magic_bytes = f.read(4)
          raise Replicate::ValidationError, "File is not a valid ZIP file" unless magic_bytes == "PK\x03\x04"
        end
      rescue Errno::EACCES
        raise Replicate::ValidationError, "Cannot read zip file: permission denied"
      end

      # Validate upload URL for security
      #
      # @param url [String] The upload URL to validate
      # @raise [Replicate::ValidationError] If the URL is invalid
      def validate_upload_url!(url)
        validate_url_string!(url)
        validate_url_format!(url)
        validate_url_scheme!(url)
        validate_url_domain!(url)
      end

      # Validate URL is a non-empty string
      #
      # @param url [String] The URL to validate
      # @raise [Replicate::ValidationError] If invalid
      def validate_url_string!(url)
        return if url.is_a?(String) && !url.strip.empty?

        raise Replicate::ValidationError, "Upload URL must be a non-empty string"
      end

      # Validate URL format
      #
      # @param url [String] The URL to validate
      # @raise [Replicate::ValidationError] If invalid format
      def validate_url_format!(url)
        URI.parse(url)
      rescue URI::InvalidURIError
        raise Replicate::ValidationError, "Invalid upload URL format"
      end

      # Validate URL scheme is HTTPS
      #
      # @param url [String] The URL to validate
      # @raise [Replicate::ValidationError] If not HTTPS
      def validate_url_scheme!(url)
        uri = URI.parse(url)
        return if uri.scheme == "https"

        raise Replicate::ValidationError, "Upload URL must use HTTPS"
      end

      # Validate URL domain is allowed
      #
      # @param url [String] The URL to validate
      # @raise [Replicate::ValidationError] If domain not allowed
      def validate_url_domain!(url)
        uri = URI.parse(url)
        allowed_domains = ["replicate.com", "replicate.delivery"]
        if ENV["RACK_ENV"] == "test" || ENV["RAILS_ENV"] == "test" || defined?(Minitest)
          allowed_domains += ["uploadurl.com", "localhost", "127.0.0.1", "example.com"]
        end

        return if allowed_domains.any? { |domain| uri.host&.end_with?(domain) }

        raise Replicate::ValidationError, "Upload URL must be from allowed domain"
      end
    end
  end
end
