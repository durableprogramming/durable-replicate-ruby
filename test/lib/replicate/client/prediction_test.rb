# frozen_string_literal: true

require "test_helper"

module Replicate
  class PredictionTest < Minitest::Test
    def setup
      @client = Replicate::Client.new(api_token: "test_token", webhook_url: nil)
    end

    def test_retrieve_prediction
      response = {
        "id" => "test-prediction-id",
        "status" => "succeeded",
        "output" => ["https://example.com/generated-image.png"]
      }

      stub_request(:get, "https://api.replicate.com/v1/predictions/test-prediction-id")
        .to_return(status: 200, body: response.to_json)

      prediction = @client.retrieve_prediction("test-prediction-id")
      assert_instance_of Replicate::Record::Prediction, prediction
      assert_equal "test-prediction-id", prediction.id
      assert_equal "succeeded", prediction.status
    end

    def test_list_predictions
      response = {
        "results" => [
          { "id" => "pred-1", "status" => "succeeded" },
          { "id" => "pred-2", "status" => "processing" }
        ],
        "next" => "https://api.replicate.com/v1/predictions?cursor=next-cursor"
      }

      stub_request(:get, "https://api.replicate.com/v1/predictions")
        .to_return(status: 200, body: response.to_json)

      predictions = @client.list_predictions
      assert_instance_of Array, predictions["results"]
      assert_equal 2, predictions["results"].size
      predictions["results"].each do |pred|
        assert_instance_of Replicate::Record::Prediction, pred
      end
    end

    def test_list_predictions_with_cursor
      response = {
        "results" => [{ "id" => "pred-1", "status" => "succeeded" }]
      }

      stub_request(:get, "https://api.replicate.com/v1/predictions?cursor=test-cursor")
        .to_return(status: 200, body: response.to_json)

      predictions = @client.list_predictions("test-cursor")
      assert_equal 1, predictions["results"].size
    end

    def test_create_prediction
      request_body = {
        version: "model-version-id",
        input: { prompt: "a cat" }
      }

      response = {
        "id" => "new-prediction-id",
        "status" => "starting",
        "input" => { "prompt" => "a cat" }
      }

      stub_request(:post, "https://api.replicate.com/v1/predictions")
        .with(body: request_body.to_json)
        .to_return(status: 201, body: response.to_json)

      prediction = @client.create_prediction(request_body)
      assert_instance_of Replicate::Record::Prediction, prediction
      assert_equal "new-prediction-id", prediction.id
      assert_equal "starting", prediction.status
    end

    def test_create_prediction_with_webhook
      client = Replicate::Client.new(api_token: "test", webhook_url: "https://example.com/webhook")

      request_body = {
        version: "model-version-id",
        input: { prompt: "a cat" }
      }

      expected_body = request_body.merge(webhook: "https://example.com/webhook")

      stub_request(:post, "https://api.replicate.com/v1/predictions")
        .with(body: expected_body.to_json)
        .to_return(status: 201, body: { "id" => "pred-id" }.to_json)

      prediction = client.create_prediction(request_body)
      assert_equal "pred-id", prediction.id
    end

    def test_cancel_prediction
      response = {
        "id" => "test-prediction-id",
        "status" => "canceled"
      }

      stub_request(:post, "https://api.replicate.com/v1/predictions/test-prediction-id/cancel")
        .to_return(status: 200, body: response.to_json)

      prediction = @client.cancel_prediction("test-prediction-id")
      assert_instance_of Replicate::Record::Prediction, prediction
      assert_equal "canceled", prediction.status
    end

    def test_prediction_methods_handle_api_errors
      stub_request(:get, "https://api.replicate.com/v1/predictions/invalid-id")
        .to_return(status: 404, body: { "detail" => "Prediction not found" }.to_json)

      assert_raises(Replicate::Error) do
        @client.retrieve_prediction("invalid-id")
      end
    end
  end
end
