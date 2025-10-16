# frozen_string_literal: true

require "test_helper"
require "replicate/endpoint"

module Replicate
  class EndpointGetTest < Minitest::Test
    class MockEndpoint
      include Replicate::EndpointGet

      attr_accessor :validated_url, :request_called_with

      def validate_url!(url)
        @validated_url = url
      end

      def request(method, url, options)
        @request_called_with = [method, url, options]
        { "mock" => "response" }
      end
    end

    class MockEndpointWithValidationError
      include Replicate::EndpointGet

      def validate_url!(url)
        raise ArgumentError, "Invalid URL: #{url}"
      end

      def request(method, url, options)
        # Should not be called
      end
    end

    def setup
      @endpoint = MockEndpoint.new
    end

    def test_get_calls_validate_url
      @endpoint.get("/test")
      assert_equal "/test", @endpoint.validated_url
    end

    def test_get_calls_request_with_get_method
      @endpoint.get("/test")
      assert_equal [:get, "/test", {}], @endpoint.request_called_with
    end

    def test_get_passes_options_to_request
      options = { param: "value" }
      @endpoint.get("/test", options)
      assert_equal [:get, "/test", options], @endpoint.request_called_with
    end

    def test_get_returns_request_result
      response = @endpoint.get("/test")
      assert_equal({ "mock" => "response" }, response)
    end

    def test_get_with_empty_options
      @endpoint.get("/test", {})
      assert_equal [:get, "/test", {}], @endpoint.request_called_with
    end

    def test_get_with_nil_options
      @endpoint.get("/test", nil)
      assert_equal [:get, "/test", nil], @endpoint.request_called_with
    end

    def test_get_with_complex_options
      options = { query: { key: "value" }, headers: { "X-Test" => "test" } }
      @endpoint.get("/test", options)
      assert_equal [:get, "/test", options], @endpoint.request_called_with
    end

    def test_get_with_numeric_url
      @endpoint.get(123)
      assert_equal 123, @endpoint.validated_url
    end

    def test_get_with_symbol_url
      @endpoint.get(:test)
      assert_equal :test, @endpoint.validated_url
    end

    def test_get_with_empty_string_url
      @endpoint.get("")
      assert_equal "", @endpoint.validated_url
    end

    def test_get_with_nil_url
      @endpoint.get(nil)
      assert_nil @endpoint.validated_url
    end

    def test_get_raises_validation_error
      endpoint = MockEndpointWithValidationError.new
      assert_raises(ArgumentError) { endpoint.get("invalid url") }
    end

    def test_get_validation_error_message
      endpoint = MockEndpointWithValidationError.new
      error = assert_raises(ArgumentError) { endpoint.get("../path") }
      assert_equal "Invalid URL: ../path", error.message
    end

    def test_get_with_special_characters_in_url
      @endpoint.get("/path-with_special.chars_123")
      assert_equal "/path-with_special.chars_123", @endpoint.validated_url
    end

    def test_get_with_unicode_url
      @endpoint.get("/café")
      assert_equal "/café", @endpoint.validated_url
    end

    def test_get_with_long_url
      long_url = "/#{"a" * 1000}"
      @endpoint.get(long_url)
      assert_equal long_url, @endpoint.validated_url
    end

    def test_get_with_empty_options_hash
      @endpoint.get("/test", {})
      assert_equal [:get, "/test", {}], @endpoint.request_called_with
    end

    def test_get_with_nested_options
      options = { query: { nested: { key: "value" } } }
      @endpoint.get("/test", options)
      assert_equal [:get, "/test", options], @endpoint.request_called_with
    end

    def test_get_with_array_options
      options = { params: %w[a b c] }
      @endpoint.get("/test", options)
      assert_equal [:get, "/test", options], @endpoint.request_called_with
    end
  end
end
