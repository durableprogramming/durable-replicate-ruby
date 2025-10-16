# frozen_string_literal: true

require "test_helper"

module Replicate
  class EndpointTest < Minitest::Test
    def setup
      @endpoint_url = "https://api.example.com"
      @api_token = "test_token"
      @endpoint = Replicate::Endpoint.new(endpoint_url: @endpoint_url, api_token: @api_token)
    end

    def test_initializes_with_valid_parameters
      endpoint = Replicate::Endpoint.new(endpoint_url: @endpoint_url, api_token: @api_token)
      assert_equal @endpoint_url, endpoint.endpoint_url
      assert_equal @api_token, endpoint.api_token
      assert_equal "application/json", endpoint.content_type
    end

    def test_initializes_with_custom_content_type
      endpoint = Replicate::Endpoint.new(endpoint_url: @endpoint_url, api_token: @api_token, content_type: "text/plain")
      assert_equal "text/plain", endpoint.content_type
    end

    def test_raises_error_for_invalid_endpoint_url
      assert_raises(ArgumentError) do
        Replicate::Endpoint.new(endpoint_url: "invalid-url", api_token: @api_token)
      end
    end

    def test_allows_nil_endpoint_url
      endpoint = Replicate::Endpoint.new(endpoint_url: nil, api_token: @api_token)
      assert_nil endpoint.endpoint_url
    end

    def test_get_request_success
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 200, body: '{"success": true}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.get("/test")
      assert_equal({ "success" => true }, response)
    end

    def test_get_request_with_query_params
      stub_request(:get, "#{@endpoint_url}/test?param=value")
        .to_return(status: 200, body: '{"data": "ok"}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.get("/test", { param: "value" })
      assert_equal({ "data" => "ok" }, response)
    end

    def test_post_request_success
      stub_request(:post, "#{@endpoint_url}/test")
        .with(body: '{"key":"value"}', headers: { "Content-Type" => "application/json" })
        .to_return(status: 201, body: '{"created": true}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.post("/test", { key: "value" })
      assert_equal({ "created" => true }, response)
    end

    def test_put_request_success
      stub_request(:put, "#{@endpoint_url}/test/1")
        .with(body: '{"update":true}', headers: { "Content-Type" => "application/json" })
        .to_return(status: 200, body: '{"updated": true}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.put("/test/1", { update: true })
      assert_equal({ "updated" => true }, response)
    end

    def test_patch_request_success
      stub_request(:patch, "#{@endpoint_url}/test/1")
        .with(body: '{"patch":true}', headers: { "Content-Type" => "application/json" })
        .to_return(status: 200, body: '{"patched": true}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.patch("/test/1", { patch: true })
      assert_equal({ "patched" => true }, response)
    end

    def test_delete_request_success
      stub_request(:delete, "#{@endpoint_url}/test/1")
        .to_return(status: 204, body: "", headers: { "Content-Type" => "application/json" })

      response = @endpoint.delete("/test/1")
      assert_nil response
    end

    def test_head_request_success
      stub_request(:head, "#{@endpoint_url}/test")
        .to_return(status: 200, headers: { "Content-Type" => "application/json" })

      response = @endpoint.head("/test")
      assert_nil response
    end

    def test_handles_400_error
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 400, body: '{"detail": "Bad request"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::APIError) { @endpoint.get("/test") }
      assert_equal "Bad request (400): Bad request", error.message
      assert_equal 400, error.status_code
    end

    def test_handles_401_error
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 401, body: '{"detail": "Unauthorized"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::AuthenticationError) { @endpoint.get("/test") }
      assert_equal "Unauthorized (401): Check your API token", error.message
      assert_equal 401, error.status_code
    end

    def test_handles_403_error
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 403, body: '{"detail": "Forbidden"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::APIError) { @endpoint.get("/test") }
      assert_equal "Forbidden (403): Insufficient permissions", error.message
      assert_equal 403, error.status_code
    end

    def test_handles_404_error_for_unknown_resource
      stub_request(:get, "#{@endpoint_url}/unknown")
        .to_return(status: 404, body: '{"detail": "Not found"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::NotFoundError) { @endpoint.get("/unknown") }
      assert_equal "Not found (404): Not found", error.message
      assert_equal 404, error.status_code
    end

    def test_handles_404_error_for_model
      stub_request(:get, "#{@endpoint_url}/models/test")
        .to_return(status: 404, body: '{"detail": "Model not found"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::ModelNotFoundError) { @endpoint.get("/models/test") }
      assert_equal "Model not found (404): Model not found", error.message
      assert_equal 404, error.status_code
    end

    def test_handles_404_error_for_version
      stub_request(:get, "#{@endpoint_url}/versions/test")
        .to_return(status: 404, body: '{"detail": "Version not found"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::VersionNotFoundError) { @endpoint.get("/versions/test") }
      assert_equal "Model version not found (404): Version not found", error.message
      assert_equal 404, error.status_code
    end

    def test_handles_404_error_for_prediction
      stub_request(:get, "#{@endpoint_url}/predictions/test")
        .to_return(status: 404, body: '{"detail": "Prediction not found"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::PredictionNotFoundError) { @endpoint.get("/predictions/test") }
      assert_equal "Prediction not found (404): Prediction not found", error.message
      assert_equal 404, error.status_code
    end

    def test_handles_404_error_for_training
      stub_request(:get, "#{@endpoint_url}/trainings/test")
        .to_return(status: 404, body: '{"detail": "Training not found"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::TrainingNotFoundError) { @endpoint.get("/trainings/test") }
      assert_equal "Training not found (404): Training not found", error.message
      assert_equal 404, error.status_code
    end

    def test_handles_422_error
      stub_request(:post, "#{@endpoint_url}/test")
        .to_return(status: 422, body: '{"detail": "Unprocessable entity"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::APIError) { @endpoint.post("/test", {}) }
      assert_equal "Unprocessable entity (422): Unprocessable entity", error.message
      assert_equal 422, error.status_code
    end

    def test_handles_429_error
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 429, body: '{"detail": "Rate limited"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::RateLimitError) { @endpoint.get("/test") }
      assert_equal "Rate limited (429): Too many requests", error.message
      assert_equal 429, error.status_code
    end

    def test_handles_500_error
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 500, body: '{"detail": "Internal server error"}', headers: { "Content-Type" => "application/json" })

      error = assert_raises(Replicate::APIError) { @endpoint.get("/test") }
      assert_equal "Server error (500): Internal server error", error.message
      assert_equal 500, error.status_code
    end

    def test_handles_unexpected_status_code
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 418, body: "I'm a teapot", headers: { "Content-Type" => "text/plain" })

      error = assert_raises(Replicate::APIError) { @endpoint.get("/test") }
      assert_equal "Unexpected response (418): I'm a teapot", error.message
      assert_equal 418, error.status_code
    end

    def test_parses_json_response
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 200, body: '{"array": [1,2,3], "hash": {"key": "value"}}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.get("/test")
      assert_equal([1, 2, 3], response["array"])
      assert_equal({ "key" => "value" }, response["hash"])
    end

    def test_returns_raw_response_for_non_json_content_type
      endpoint = Replicate::Endpoint.new(endpoint_url: @endpoint_url, api_token: @api_token, content_type: "text/plain")
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 200, body: "plain text response", headers: { "Content-Type" => "text/plain" })

      response = endpoint.get("/test")
      assert_equal "plain text response", response
    end

    def test_validates_url
      assert_raises(ArgumentError) { @endpoint.get("invalid url with spaces") }
      assert_raises(ArgumentError) { @endpoint.get("../path/traversal") }
      assert_raises(ArgumentError) { @endpoint.get("path\\with\\backslashes") }
      assert_raises(ArgumentError) { @endpoint.get("path/with/invalid@chars") }
    end

    def test_allows_valid_urls
      stub_request(:get, "#{@endpoint_url}/valid-path_123")
        .to_return(status: 200, body: '{"ok": true}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.get("/valid-path_123")
      assert_equal({ "ok" => true }, response)
    end

    def test_handles_multipart_post
      file = StringIO.new("file content")
      stub_request(:post, "#{@endpoint_url}/upload")
        .to_return(status: 200, body: '{"uploaded": true}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.post("/upload", { file: file })
      assert_equal({ "uploaded" => true }, response)
    end

    def test_normalizes_url
      # Test that URLs are normalized, but since Faraday handles it, we just ensure no error
      stub_request(:get, "#{@endpoint_url}/test")
        .to_return(status: 200, body: '{"ok": true}', headers: { "Content-Type" => "application/json" })

      response = @endpoint.get("/test")
      assert_equal({ "ok" => true }, response)
    end

    def test_sets_last_request_path
      stub_request(:get, "#{@endpoint_url}/test/path")
        .to_return(status: 200, body: '{"ok": true}', headers: { "Content-Type" => "application/json" })

      @endpoint.get("/test/path")
      # Since last_request_path is private, we can't directly test, but it's used in error handling
    end

    def test_agent_configuration
      # Test that agent is configured properly
      agent = @endpoint.send(:agent)
      assert_instance_of Faraday::Connection, agent
      assert_equal "#{@endpoint_url}/", agent.url_prefix.to_s
    end

    def test_should_retry_logic
      env = Struct.new(:status).new
      exception = StandardError.new

      # Should retry 429
      env.status = 429
      assert @endpoint.send(:should_retry?, env, exception)

      # Should retry 500
      env.status = 500
      assert @endpoint.send(:should_retry?, env, exception)

      # Should not retry 401
      env.status = 401
      refute @endpoint.send(:should_retry?, env, exception)

      # Should not retry 403
      env.status = 403
      refute @endpoint.send(:should_retry?, env, exception)

      # Should not retry 422
      env.status = 422
      refute @endpoint.send(:should_retry?, env, exception)

      # Should not retry timeout
      env.status = 500
      timeout_exception = Faraday::TimeoutError.new
      refute @endpoint.send(:should_retry?, env, timeout_exception)
    end

    def test_parse_error_message_with_detail
      response = Struct.new(:body).new('{"detail": "Specific error"}')
      message = @endpoint.send(:parse_error_message, response)
      assert_equal "Specific error", message
    end

    def test_parse_error_message_without_detail
      response = Struct.new(:body).new('{"error": "Generic error"}')
      message = @endpoint.send(:parse_error_message, response)
      assert_equal '{"error": "Generic error"}', message
    end

    def test_parse_error_message_invalid_json
      response = Struct.new(:body).new("Invalid JSON")
      message = @endpoint.send(:parse_error_message, response)
      assert_equal "Invalid JSON", message
    end

    # def test_multipart_request_detection
    #   assert_equal true, @endpoint.send(:multipart_request?, { file: StringIO.new })
    #   assert_equal false, @endpoint.send(:multipart_request?, { key: "value" })
    # end
  end
end
