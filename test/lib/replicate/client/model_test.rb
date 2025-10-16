# frozen_string_literal: true

require "test_helper"

module Replicate
  class ModelTest < Minitest::Test
    def setup
      @client = Replicate::Client.new(api_token: "test_token")
    end

    def test_retrieve_model_with_latest_version
      response = {
        "url" => "https://replicate.com/stability-ai/stable-diffusion",
        "owner" => "stability-ai",
        "name" => "stable-diffusion",
        "description" => "A latent text-to-image diffusion model",
        "latest_version" => {
          "id" => "test-version-id",
          "created_at" => "2022-08-31T21:06:15.330778Z"
        }
      }

      stub_request(:get, "https://api.replicate.com/v1/models/stability-ai/stable-diffusion")
        .to_return(status: 200, body: response.to_json)

      model = @client.retrieve_model("stability-ai/stable-diffusion")
      assert_instance_of Replicate::Record::Model, model
      assert_equal "stable-diffusion", model.name
      assert_equal "stability-ai", model.owner
      assert_instance_of Replicate::Record::ModelVersion, model.latest_version
    end

    def test_retrieve_model_with_all_versions
      response = {
        "results" => [
          { "id" => "version-1", "created_at" => "2022-01-01T00:00:00Z" },
          { "id" => "version-2", "created_at" => "2022-02-01T00:00:00Z" }
        ]
      }

      stub_request(:get, "https://api.replicate.com/v1/models/stability-ai/stable-diffusion/versions")
        .to_return(status: 200, body: response.to_json)

      versions = @client.retrieve_model("stability-ai/stable-diffusion", version: :all)
      assert_instance_of Array, versions
      assert_equal 2, versions.size
      versions.each do |version|
        assert_instance_of Replicate::Record::ModelVersion, version
      end
    end

    def test_retrieve_model_with_specific_version
      response = {
        "id" => "specific-version-id",
        "created_at" => "2022-08-31T21:06:15.330778Z"
      }

      stub_request(:get, "https://api.replicate.com/v1/models/stability-ai/stable-diffusion/versions/specific-version-id")
        .to_return(status: 200, body: response.to_json)

      version = @client.retrieve_model("stability-ai/stable-diffusion", version: "specific-version-id")
      assert_instance_of Replicate::Record::ModelVersion, version
      assert_equal "specific-version-id", version.id
    end

    def test_retrieve_collection
      response = {
        "name" => "text-to-image",
        "description" => "Models for generating images from text",
        "models" => []
      }

      stub_request(:get, "https://api.replicate.com/v1/collections/text-to-image")
        .to_return(status: 200, body: response.to_json)

      collection = @client.retrieve_collection("text-to-image")
      assert_equal "text-to-image", collection["name"]
      assert_equal "Models for generating images from text", collection["description"]
    end

    def test_retrieve_model_handles_api_errors
      stub_request(:get, "https://api.replicate.com/v1/models/invalid/model")
        .to_return(status: 404, body: { "detail" => "Model not found" }.to_json)

      assert_raises(Replicate::Error) do
        @client.retrieve_model("invalid/model")
      end
    end

    def test_retrieve_model_with_invalid_version_type
      assert_raises(Replicate::ValidationError) do
        @client.retrieve_model("stability-ai/stable-diffusion", version: 123)
      end
    end
  end
end
