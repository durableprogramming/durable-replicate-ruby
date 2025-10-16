# frozen_string_literal: true

require "test_helper"

module Replicate
  class TrainingTest < Minitest::Test
    def setup
      @client = Replicate::Client.new(api_token: "test_token", webhook_url: nil)
    end

    def test_retrieve_training
      response = {
        "id" => "training-123",
        "status" => "succeeded",
        "created_at" => "2023-01-01T00:00:00Z",
        "input" => {
          "instance_prompt" => "photo of zwx person",
          "class_prompt" => "photo of person"
        },
        "output" => {
          "version" => "version-456"
        }
      }

      stub_request(:get, "https://dreambooth-api-experimental.replicate.com/v1/trainings/training-123")
        .to_return(status: 200, body: response.to_json)

      training = @client.retrieve_training("training-123")
      assert_instance_of Replicate::Record::Training, training
      assert_equal "training-123", training.id
      assert_equal "succeeded", training.status
    end

    def test_create_training
      params = {
        input: {
          instance_prompt: "photo of zwx person",
          class_prompt: "photo of person",
          instance_data: "https://example.com/data.zip",
          max_train_steps: 2000
        },
        model: "myusername/my-model"
      }

      response = {
        "id" => "training-456",
        "status" => "starting",
        "created_at" => "2023-01-01T00:00:00Z",
        "input" => params[:input],
        "model" => params[:model]
      }

      stub_request(:post, "https://dreambooth-api-experimental.replicate.com/v1/trainings")
        .with(body: params.merge(webhook: nil).to_json)
        .to_return(status: 201, body: response.to_json)

      training = @client.create_training(params)
      assert_instance_of Replicate::Record::Training, training
      assert_equal "training-456", training.id
      assert_equal "starting", training.status
    end

    def test_create_training_with_webhook
      params = {
        input: {
          instance_prompt: "photo of zwx person",
          class_prompt: "photo of person",
          instance_data: "https://example.com/data.zip",
          max_train_steps: 2000
        },
        model: "myusername/my-model",
        webhook: "https://example.com/webhook"
      }

      response = {
        "id" => "training-789",
        "status" => "starting",
        "created_at" => "2023-01-01T00:00:00Z",
        "input" => params[:input],
        "model" => params[:model]
      }

      stub_request(:post, "https://dreambooth-api-experimental.replicate.com/v1/trainings")
        .with(body: params.to_json)
        .to_return(status: 201, body: response.to_json)

      training = @client.create_training(params)
      assert_instance_of Replicate::Record::Training, training
      assert_equal "training-789", training.id
    end

    def test_retrieve_training_handles_api_errors
      stub_request(:get, "https://dreambooth-api-experimental.replicate.com/v1/trainings/invalid-id")
        .to_return(status: 404, body: { "detail" => "Training not found" }.to_json)

      assert_raises(Replicate::Error) do
        @client.retrieve_training("invalid-id")
      end
    end

    def test_create_training_handles_api_errors
      params = {
        input: { instance_prompt: "test" },
        model: "invalid/model"
      }

      stub_request(:post, "https://dreambooth-api-experimental.replicate.com/v1/trainings")
        .to_return(status: 400, body: { "detail" => "Invalid parameters" }.to_json)

      assert_raises(Replicate::Error) do
        @client.create_training(params)
      end
    end
  end
end
