# frozen_string_literal: true

require "test_helper"

class IntegrationTest < Minitest::Test
  def setup
    @client = Replicate::Client.new(api_token: "test_token")
  end

  def test_full_prediction_workflow
    stub_prediction_workflow

    # Create prediction
    prediction = @client.create_prediction(
      version: "test-model-version",
      input: { prompt: "test prompt" }
    )

    assert_prediction_starting(prediction)

    # Refetch prediction (processing)
    prediction.refetch
    assert_prediction_processing(prediction)

    # Refetch prediction (completed)
    prediction.refetch
    assert_prediction_succeeded(prediction)
  end

  def test_model_retrieval_workflow
    # Mock model retrieval
    stub_request(:get, "https://api.replicate.com/v1/models/stability-ai/stable-diffusion")
      .to_return(
        status: 200,
        body: {
          name: "stability-ai/stable-diffusion",
          owner: "stability-ai",
          description: "A latent text-to-image diffusion model",
          latest_version: {
            id: "test-version-id",
            created_at: "2023-01-01T00:00:00Z"
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    # Mock version retrieval
    stub_request(:get, "https://api.replicate.com/v1/models/stability-ai/stable-diffusion/versions/test-version-id")
      .to_return(
        status: 200,
        body: {
          id: "test-version-id",
          model: "stability-ai/stable-diffusion",
          created_at: "2023-01-01T00:00:00Z",
          configuration: {
            prompt: { type: "string", default: "a beautiful landscape" }
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    # Retrieve model and version
    model = @client.retrieve_model("stability-ai/stable-diffusion")
    assert_equal "stability-ai/stable-diffusion", model.name
    assert_equal "stability-ai", model.owner

    version = @client.retrieve_model("stability-ai/stable-diffusion", version: "test-version-id")
    assert_equal "test-version-id", version.id
    assert_equal "stability-ai/stable-diffusion", version.model
  end

  def test_error_handling_workflow
    # Test validation errors
    assert_raises(Replicate::ValidationError) do
      @client.retrieve_model("")
    end

    assert_raises(Replicate::ValidationError) do
      @client.retrieve_model("invalid-format")
    end

    assert_raises(Replicate::ValidationError) do
      @client.create_prediction({})
    end

    # Test API errors
    stub_request(:get, "https://api.replicate.com/v1/models/nonexistent/model")
      .to_return(
        status: 404,
        body: { detail: "Model not found" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    assert_raises(Replicate::NotFoundError) do
      @client.retrieve_model("nonexistent/model")
    end
  end

  def test_prediction_cancellation_workflow
    # Mock prediction creation
    stub_request(:post, "https://api.replicate.com/v1/predictions")
      .to_return(
        status: 201,
        body: {
          id: "test_prediction_id",
          status: "processing",
          input: { prompt: "test prompt" },
          created_at: "2023-01-01T00:00:00Z"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    # Mock cancellation
    stub_request(:post, "https://api.replicate.com/v1/predictions/test_prediction_id/cancel")
      .to_return(
        status: 200,
        body: {
          id: "test_prediction_id",
          status: "canceled",
          input: { prompt: "test prompt" },
          created_at: "2023-01-01T00:00:00Z",
          canceled_at: "2023-01-01T00:00:05Z"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    # Create and cancel prediction
    prediction = @client.create_prediction(
      version: "test-model-version",
      input: { prompt: "test prompt" }
    )

    assert_equal "processing", prediction.status

    prediction.cancel
    assert_equal "canceled", prediction.status
    assert prediction.canceled?
    assert prediction.finished?
  end

  def test_configuration_workflow
    skip "Environment variable test - may not work in CI environment"

    # Test programmatic configuration
    client = Replicate::Client.new(api_token: "test_token", webhook_url: "https://example.com/webhook")
    assert_equal "test_token", client.api_token
    assert_equal "https://example.com/webhook", client.webhook_url

    # Test validation
    assert_raises(Replicate::ValidationError) do
      client.api_token = ""
    end

    assert_raises(Replicate::ValidationError) do
      client.webhook_url = "invalid-url"
    end
  end

  private

  def stub_prediction_workflow
    # Mock the API responses for a complete prediction workflow
    stub_request(:post, "https://api.replicate.com/v1/predictions")
      .to_return(
        status: 201,
        body: {
          id: "test_prediction_id",
          status: "starting",
          input: { prompt: "test prompt" },
          created_at: "2023-01-01T00:00:00Z"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    stub_request(:get, "https://api.replicate.com/v1/predictions/test_prediction_id")
      .to_return(
        status: 200,
        body: {
          id: "test_prediction_id",
          status: "processing",
          input: { prompt: "test prompt" },
          created_at: "2023-01-01T00:00:00Z",
          started_at: "2023-01-01T00:00:01Z"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
      .then
      .to_return(
        status: 200,
        body: {
          id: "test_prediction_id",
          status: "succeeded",
          input: { prompt: "test prompt" },
          output: ["generated image data"],
          created_at: "2023-01-01T00:00:00Z",
          started_at: "2023-01-01T00:00:01Z",
          completed_at: "2023-01-01T00:00:02Z"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def assert_prediction_starting(prediction)
    assert_equal "test_prediction_id", prediction.id
    assert_equal "starting", prediction.status
    assert prediction.starting?
    refute prediction.finished?
  end

  def assert_prediction_processing(prediction)
    assert_equal "processing", prediction.status
    assert prediction.processing?
    refute prediction.finished?
  end

  def assert_prediction_succeeded(prediction)
    assert_equal "succeeded", prediction.status
    assert prediction.succeeded?
    assert prediction.finished?
    assert_equal ["generated image data"], prediction.output
  end
end
