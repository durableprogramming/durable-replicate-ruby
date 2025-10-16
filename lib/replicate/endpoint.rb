# frozen_string_literal: true

require "faraday"
require "faraday/net_http"
require "faraday/retry"
require "faraday/multipart"
require "addressable/uri"

# Replicate API endpoint functionality
module Replicate
  require_relative "endpoint/initialize"
  require_relative "endpoint/get"
  require_relative "endpoint/post"
  require_relative "endpoint/put"
  require_relative "endpoint/patch"
  require_relative "endpoint/delete"
  require_relative "endpoint/head"
  require_relative "endpoint/agent"
  require_relative "endpoint/last_response"

  # Network layer for Replicate API clients
  #
  # Handles HTTP requests to Replicate APIs with proper error handling,
  # retries, and response parsing.
  class Endpoint
    include Replicate::EndpointInitialize
    include Replicate::EndpointGet
    include Replicate::EndpointPost
    include Replicate::EndpointPut
    include Replicate::EndpointPatch
    include Replicate::EndpointDelete
    include Replicate::EndpointHead
    include Replicate::EndpointAgent
    include Replicate::EndpointLastResponse

    # @return [String] The base endpoint URL
    attr_reader :endpoint_url

    # @return [String, nil] The API token for authentication
    attr_reader :api_token

    # @return [String] The content type for requests
    attr_reader :content_type

    private

    # Configure Faraday agent
    #
    # @return [Faraday::Connection] Configured Faraday connection
    def configure_agent
      Faraday.new(url: endpoint_url) do |conn|
        configure_retry(conn)
        configure_requests(conn)
        configure_headers(conn)
        configure_timeouts(conn)
        configure_performance(conn)
        conn.adapter :net_http
      end
    end

    # Configure retry settings
    #
    # @param conn [Faraday::Connection] Faraday connection
    def configure_retry(conn)
      conn.request :retry, max: 3, interval: 0.5, backoff_factor: 2,
                           retry_statuses: [429, 500, 502, 503, 504],
                           retry_if: ->(env, exception) { should_retry?(env, exception) }
    end

    # Configure request settings
    #
    # @param conn [Faraday::Connection] Faraday connection
    def configure_requests(conn)
      conn.request :multipart
      conn.request :authorization, "Token", api_token if api_token
    end

    # Configure headers
    #
    # @param conn [Faraday::Connection] Faraday connection
    def configure_headers(conn)
      conn.headers["Content-Type"] = content_type
      conn.headers["User-Agent"] = "Replicate-Ruby/#{Replicate::VERSION}"
      conn.headers["Accept"] = "application/json"
    end

    # Configure timeouts
    #
    # @param conn [Faraday::Connection] Faraday connection
    def configure_timeouts(conn)
      conn.options.timeout = 30          # Total timeout
      conn.options.open_timeout = 10     # Connection timeout
      conn.options.read_timeout = 20     # Read timeout
    end

    # Configure performance settings
    #
    # @param conn [Faraday::Connection] Faraday connection
    def configure_performance(conn)
      conn.headers["Connection"] = "keep-alive"
    end

    # Determine if a request should be retried
    #
    # @param env [Faraday::Env] The request environment
    # @param exception [Exception] The exception that occurred
    # @return [Boolean] True if the request should be retried
    def should_retry?(env, exception)
      return false if exception.is_a?(Faraday::TimeoutError) # Don't retry timeouts
      return false if env.status == 401 || env.status == 403 # Don't retry auth errors
      return false if env.status == 422 # Don't retry validation errors

      true # Retry other errors
    end

    # Make an HTTP request with error handling
    #
    # @param method [Symbol] HTTP method (:get, :post, etc.)
    # @param path [String] Request path
    # @param data [String, Hash] Request body data
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::TimeoutError] If the request times out
    # @raise [Replicate::ConnectionError] If the connection fails
    # @raise [Replicate::APIError] If the API returns an error response
    def request(method, path, data)
      @last_request_path = path
      @last_response = agent.send(method, normalize_url(path), data)
      handle_response(@last_response)
    end

    # Handle HTTP response and raise appropriate errors
    #
    # @param response [Faraday::Response] The HTTP response
    # @return [Hash, Array, String] Parsed response body
    # @raise [Replicate::APIError] If the response indicates an error
    # @raise [Replicate::AuthenticationError] For authentication failures
    # @raise [Replicate::NotFoundError] For resource not found
    # @raise [Replicate::RateLimitError] For rate limiting
    def handle_response(response)
      status = response.status
      case status
      when 200..299
        parse_response_body(response)
      when 400, 422
        handle_client_error(response)
      when 401, 403, 429
        raise_error_for_status(status, response.body)
      when 404
        handle_not_found_error(response)
      when 500..599
        handle_server_error(response)
      else
        raise Replicate::APIError.new("Unexpected response (#{status}): #{response.body}", status, response.body)
      end
    end

    # Parse response body based on content type
    #
    # @param response [Faraday::Response] The HTTP response
    # @return [Hash, Array, String] Parsed response body
    def parse_response_body(response)
      return nil if response.body.nil? || response.body.empty?

      case content_type
      when "application/json"
        JSON.parse(response.body)
      else
        response.body
      end
    end

    # Raise appropriate error for HTTP status
    #
    # @param status [Integer] The HTTP status code
    # @param body [String] The response body
    # @raise [Replicate::Error] The appropriate error
    def raise_error_for_status(status, body)
      case status
      when 401
        raise Replicate::AuthenticationError.new("Unauthorized (401): Check your API token", status, body)
      when 403
        raise Replicate::APIError.new("Forbidden (403): Insufficient permissions", status, body)
      when 429
        raise Replicate::RateLimitError.new("Rate limited (429): Too many requests", status, body)
      end
    end

    # Handle client errors (400, 422)
    #
    # @param response [Faraday::Response] The HTTP response
    # @raise [Replicate::APIError] Client error
    def handle_client_error(response)
      message = case response.status
                when 400
                  "Bad request (400)"
                when 422
                  "Unprocessable entity (422)"
                end
      raise Replicate::APIError.new("#{message}: #{parse_error_message(response)}", response.status, response.body)
    end

    # Handle 404 errors with specific resource types
    #
    # @param response [Faraday::Response] The HTTP response
    # @raise [Replicate::NotFoundError] Specific not found error
    def handle_not_found_error(response)
      error_message = parse_error_message(response)
      case @last_request_path
      when %r{/models/}
        raise Replicate::ModelNotFoundError.new("Model not found (404): #{error_message}", 404, response.body)
      when %r{/versions/}
        raise Replicate::VersionNotFoundError.new("Model version not found (404): #{error_message}", 404,
                                                  response.body)
      when %r{/predictions/}
        raise Replicate::PredictionNotFoundError.new("Prediction not found (404): #{error_message}", 404,
                                                     response.body)
      when %r{/trainings/}
        raise Replicate::TrainingNotFoundError.new("Training not found (404): #{error_message}", 404, response.body)
      else
        raise Replicate::NotFoundError.new("Not found (404): #{error_message}", 404, response.body)
      end
    end

    # Handle server errors (500-599)
    #
    # @param response [Faraday::Response] The HTTP response
    # @raise [Replicate::APIError] Server error
    def handle_server_error(response)
      raise Replicate::APIError.new("Server error (#{response.status}): #{parse_error_message(response)}",
                                    response.status, response.body)
    end

    # Parse error message from response
    #
    # @param response [Faraday::Response] The HTTP response
    # @return [String] Error message
    def parse_error_message(response)
      error_data = JSON.parse(response.body)
      if error_data.is_a?(Hash) && error_data["detail"]
        error_data["detail"]
      else
        response.body
      end
    rescue JSON::ParserError
      response.body
    end

    # Check if request should be multipart
    #
    # @param options [Hash] Request options
    # @return [Boolean] True if multipart upload
    def multipart_request?(options)
      options.values.any? { |v| v.is_a?(IO) || v.is_a?(Faraday::UploadIO) }
    end

    # Normalize URL path
    #
    # @param url [String] URL path
    # @return [String] Normalized URL
    def normalize_url(url)
      Addressable::URI.parse(url.to_s).normalize.to_s
    end

    # Validate endpoint URL
    #
    # @param url [String] The endpoint URL to validate
    # @raise [ArgumentError] If URL is invalid
    def validate_endpoint_url!(url)
      return if url.nil? # Allow nil for upload endpoints

      begin
        uri = URI.parse(url)
        raise ArgumentError, "Invalid endpoint URL: #{url}" unless uri.scheme && uri.host
      rescue URI::InvalidURIError
        raise ArgumentError, "Invalid endpoint URL format: #{url}"
      end
    end

    # Validate request URL
    #
    # @param url [String] The URL to validate
    # @raise [ArgumentError] If URL is invalid
    def validate_url!(url)
      return if url.nil? || url.empty?

      raise ArgumentError, "URL must be a string, got #{url.class}" unless url.is_a?(String)

      # Prevent path traversal attacks
      raise ArgumentError, "URL contains invalid path characters" if url.include?("..") || url.include?("\\")

      # Basic URL format validation - allow alphanumeric, underscore, hyphen, slash, dot
      return if url.match?(%r{\A[[:alnum:]_/\-.]+\z})

      raise ArgumentError, "URL contains invalid characters"
    end
  end
end
