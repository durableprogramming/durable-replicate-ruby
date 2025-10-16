# frozen_string_literal: true

require "forwardable"

# Ruby client for the Replicate API
#
# This module provides a comprehensive Ruby interface to Replicate's machine learning
# model hosting platform. It supports running predictions, managing models, training
# custom models, and handling file uploads.
#
# @example Basic usage
#   require 'replicate'
#
#   Replicate.configure do |config|
#     config.api_token = 'your_api_token'
#   end
#
#   # Run a prediction
#   prediction = Replicate.client.create_prediction(
#     version: 'stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf',
#     input: { prompt: 'a beautiful landscape' }
#   )
#
# @see https://replicate.com/docs
# @see Replicate::Client
module Replicate
  # Base error class for all Replicate-related errors
  class Error < StandardError; end

  # Configuration-related errors with suggestions
  class ConfigurationError < Error
    attr_reader :suggestion

    def initialize(message, suggestion = nil)
      super(message)
      @suggestion = suggestion
    end

    def message
      if @suggestion
        "#{super}\nSuggestion: #{@suggestion}"
      else
        super
      end
    end
  end

  # API request/response errors
  class APIError < Error
    attr_reader :status_code, :response_body

    def initialize(message, status_code = nil, response_body = nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Authentication/authorization errors
  class AuthenticationError < APIError; end

  # Resource not found errors
  class NotFoundError < APIError; end

  # Model-specific errors
  class ModelError < Error; end

  # Validation errors for input parameters
  class ValidationError < Error; end

  # Rate limiting errors
  class RateLimitError < APIError; end

  # Timeout errors
  class TimeoutError < Error; end

  # Connection/network errors
  class ConnectionError < Error; end

  # Model not found errors
  class ModelNotFoundError < NotFoundError; end

  # Version not found errors
  class VersionNotFoundError < NotFoundError; end

  # Prediction not found errors
  class PredictionNotFoundError < NotFoundError; end

  # Training not found errors
  class TrainingNotFoundError < NotFoundError; end

  # Upload errors
  class UploadError < Error; end

  # Type coercion utilities for robust input handling
  module TypeCoercion
    module_function

    # Coerce value to string
    #
    # @param value [Object] The value to coerce
    # @return [String] The coerced string
    def to_string(value)
      return nil if value.nil?

      String(value)
    end

    # Coerce value to integer
    #
    # @param value [Object] The value to coerce
    # @return [Integer, nil] The coerced integer or nil
    def to_integer(value)
      return nil if value.nil?

      Integer(value)
    rescue ArgumentError, TypeError
      nil
    end

    # Coerce value to float
    #
    # @param value [Object] The value to coerce
    # @return [Float, nil] The coerced float or nil
    def to_float(value)
      return nil if value.nil?

      Float(value)
    rescue ArgumentError, TypeError
      nil
    end

    # Coerce value to boolean
    #
    # @param value [Object] The value to coerce
    # @return [Boolean] The coerced boolean
    def to_boolean(value)
      return false if value.nil?

      case value
      when TrueClass, FalseClass then value
      when String then !%w[false 0 no off].include?(value.downcase)
      when Numeric then !value.zero?
      else !!value
      end
    end

    # Coerce hash values recursively
    #
    # @param hash [Hash] The hash to coerce
    # @return [Hash] The coerced hash
    def coerce_hash_values(hash)
      return {} unless hash.is_a?(Hash)

      hash.transform_values do |value|
        case value
        when Hash then coerce_hash_values(value)
        when Array then value.map { |v| v.is_a?(Hash) ? coerce_hash_values(v) : v }
        else value
        end
      end
    end
  end

  # Autoload core components for efficient memory usage
  autoload :Client, "replicate/client"
  autoload :Configurable, "replicate/configurable"
  autoload :Endpoint, "replicate/endpoint"
  autoload :VERSION, "replicate/version"

  # Autoload record classes with hierarchical organization
  module Record
    autoload :Base, "replicate/record/base"
    autoload :Model, "replicate/record/model"
    autoload :ModelVersion, "replicate/record/model_version"
    autoload :Prediction, "replicate/record/prediction"
    autoload :Upload, "replicate/record/upload"
    autoload :Training, "replicate/record/training"

    # Mixins for shared functionality across record classes
    module Mixins
      autoload :Refreshable, "replicate/record/mixins/refreshable"
      autoload :Statusable, "replicate/record/mixins/statusable"
    end
  end

  # Autoload client mixins for modular functionality
  module ClientMixins
    autoload :Model, "replicate/client/model"
    autoload :Prediction, "replicate/client/prediction"
    autoload :Upload, "replicate/client/upload"
    autoload :Training, "replicate/client/training"
  end

  class << self
    include Replicate::Configurable
    extend Forwardable

    # Creates or returns the configured client instance
    #
    # @return [Replicate::Client] The configured client instance
    def client
      return @client if defined?(@client)

      @client = Replicate::Client.new(options)
    end

    # Delegate common client methods to the client instance for convenience
    def_delegators :client, :retrieve_model, :create_prediction, :retrieve_prediction,
                   :list_predictions, :upload_zip, :create_training, :retrieve_training

    # Factory methods for convenient object creation

    # Creates a prediction with the given parameters
    #
    # @param version [String] The model version identifier
    # @param input [Hash] The input parameters for the prediction
    # @param webhook [String, nil] Optional webhook URL
    # @return [Replicate::Record::Prediction] The created prediction
    # @example Create a prediction
    #   prediction = Replicate.predict("stability-ai/stable-diffusion:db21e45d...", prompt: "a cat")
    def predict(version, input = {}, webhook: nil)
      client.create_prediction(version: version, input: input, webhook: webhook)
    end

    # Retrieves a model by identifier
    #
    # @param identifier [String] The model identifier in format "owner/name"
    # @param version [String, Symbol] The version to retrieve (:latest, :all, or specific version)
    # @return [Replicate::Record::Model, Array<Replicate::Record::ModelVersion>, Replicate::Record::ModelVersion]
    # @example Get the latest version of a model
    #   model = Replicate.model("stability-ai/stable-diffusion")
    def model(identifier, version: :latest)
      client.retrieve_model(identifier, version: version)
    end
  end
end
