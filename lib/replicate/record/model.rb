# frozen_string_literal: true

module Replicate
  module Record
    # Represents a Replicate model with its metadata and latest version
    #
    # @see https://replicate.com/docs/reference/http#models.list
    class Model < Base
      # Initializes a new Model instance
      #
      # @param client [Replicate::Client] The client instance
      # @param params [Hash] The model data from the API
      # @option params [String] :url The model URL
      # @option params [String] :owner The model owner username
      # @option params [String] :name The model name
      # @option params [String] :description The model description
      # @option params [Hash] :latest_version The latest version data
      def initialize(client, params)
        if params["latest_version"]
          params["latest_version"] =
            Replicate::Record::ModelVersion.new(client, params["latest_version"])
        end
        super
      end

      # Returns the latest version of this model
      #
      # @return [Replicate::Record::ModelVersion] The latest model version
      def latest_version
        data["latest_version"]
      end

      # Returns all versions of this model (lazy loaded)
      #
      # @return [Array<Replicate::Record::ModelVersion>] All model versions
      def versions
        @versions ||= client.retrieve_model("#{owner}/#{name}", version: :all)
      end

      # Returns the model identifier in "owner/name" format
      #
      # @return [String] The model identifier
      def identifier
        "#{data["owner"] || ""}/#{data["name"] || ""}"
      end
    end
  end
end
