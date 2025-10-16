# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Methods for interacting with Replicate models and collections
    module Model
      # Retrieves a model from Replicate
      #
      # @param model [String] The model identifier in the format "owner/name"
      # @param version [String, Symbol] The version to retrieve (:latest, :all, or specific version ID)
      # @return [Replicate::Record::Model, Array<Replicate::Record::ModelVersion>, Replicate::Record::ModelVersion]
      #   Returns a Model instance for :latest, an array of ModelVersion instances for :all,
      #   or a single ModelVersion instance for a specific version
      # @raise [Replicate::ValidationError] If model identifier is invalid
      # @raise [Replicate::APIError] If the API request fails
      # @see https://replicate.com/docs/reference/http#get-model
      # @example Retrieve the latest version of a model
      #   model = client.retrieve_model("stability-ai/stable-diffusion")
      # @example Retrieve all versions of a model
      #   versions = client.retrieve_model("stability-ai/stable-diffusion", version: :all)
      # @example Retrieve a specific version of a model
      #   version = client.retrieve_model("stability-ai/stable-diffusion", version: "some-version-id")
      def retrieve_model(model, version: :latest)
        validate_model_identifier!(model)
        validate_version_parameter!(version)

        cache_key = "#{model}:#{version}"

        # Performance: Check cache first (skip for :all to avoid stale data)
        return @model_cache[cache_key] if version != :all && @model_cache[cache_key]

        fetch_model_data(model, version, cache_key)
      end

      # Retrieves a collection of models from Replicate
      #
      # @param slug [String] The collection slug identifier
      # @return [Hash] The collection data including models
      # @raise [Replicate::ValidationError] If collection slug is invalid
      # @raise [Replicate::APIError] If the API request fails
      # @see https://replicate.com/docs/reference/http#get-collection
      # @example Retrieve a collection
      #   collection = client.retrieve_collection("text-to-image")
      def retrieve_collection(slug)
        validate_collection_slug!(slug)
        api_endpoint.get("collections/#{slug}")
      end

      private

      # Fetch model data based on version
      #
      # @param model [String] The model identifier
      # @param version [String, Symbol] The version to fetch
      # @param cache_key [String] The cache key
      # @return [Replicate::Record::Model, Array<Replicate::Record::ModelVersion>, Replicate::Record::ModelVersion]
      def fetch_model_data(model, version, cache_key)
        case version
        when :latest
          response = api_endpoint.get("models/#{model}")
          model_instance = Replicate::Record::Model.new(self, response)
          @model_cache[cache_key] = model_instance
          model_instance
        when :all
          response = api_endpoint.get("models/#{model}/versions")
          response["results"].map { |result| Replicate::Record::ModelVersion.new(self, result) }
        else
          response = api_endpoint.get("models/#{model}/versions/#{version}")
          version_instance = Replicate::Record::ModelVersion.new(self, response)
          @version_cache[cache_key] = version_instance
          version_instance
        end
      end

      # Validate model identifier format
      #
      # @param model [String] The model identifier to validate
      # @raise [Replicate::ValidationError] If the model identifier is invalid
      def validate_model_identifier!(model)
        unless model.is_a?(String) && !model.strip.empty?
          raise Replicate::ValidationError, "Model identifier must be a non-empty string"
        end

        return if model.match?(%r{\A[\w.-]+/[\w.-]+\z})

        raise Replicate::ValidationError, "Model identifier must be in format 'owner/name'"
      end

      # Validate version parameter
      #
      # @param version [String, Symbol] The version parameter to validate
      # @raise [Replicate::ValidationError] If the version parameter is invalid
      def validate_version_parameter!(version)
        return if %i[latest all].include?(version)

        return if version.is_a?(String) && !version.strip.empty?

        raise Replicate::ValidationError, "Version must be :latest, :all, or a non-empty string"
      end

      # Validate collection slug
      #
      # @param slug [String] The collection slug to validate
      # @raise [Replicate::ValidationError] If the collection slug is invalid
      def validate_collection_slug!(slug)
        unless slug.is_a?(String) && !slug.strip.empty?
          raise Replicate::ValidationError, "Collection slug must be a non-empty string"
        end

        return if slug.match?(/\A[\w.-]+\z/)

        raise Replicate::ValidationError, "Collection slug contains invalid characters"
      end
    end
  end
end
