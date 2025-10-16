# frozen_string_literal: true

require "test_helper"
require "replicate/endpoint"

module Replicate
  class EndpointHeadTest < Minitest::Test
    class MockEndpoint
      include Replicate::EndpointHead

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
      include Replicate::EndpointHead

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

    def test_head_calls_validate_url
      @endpoint.head("/test")
      assert_equal "/test", @endpoint.validated_url
    end

    def test_head_calls_request_with_head_method
      @endpoint.head("/test")
      assert_equal [:head, "/test", {}], @endpoint.request_called_with
    end

    def test_head_passes_options_to_request
      options = { param: "value" }
      @endpoint.head("/test", options)
      assert_equal [:head, "/test", options], @endpoint.request_called_with
    end

    def test_head_returns_request_result
      response = @endpoint.head("/test")
      assert_equal({ "mock" => "response" }, response)
    end

    def test_head_with_empty_options
      @endpoint.head("/test", {})
      assert_equal [:head, "/test", {}], @endpoint.request_called_with
    end

    def test_head_with_nil_options
      @endpoint.head("/test", nil)
      assert_equal [:head, "/test", nil], @endpoint.request_called_with
    end

    def test_head_with_complex_options
      options = { query: { key: "value" }, headers: { "X-Test" => "test" } }
      @endpoint.head("/test", options)
      assert_equal [:head, "/test", options], @endpoint.request_called_with
    end

    def test_head_with_numeric_url
      @endpoint.head(123)
      assert_equal 123, @endpoint.validated_url
    end

    def test_head_with_symbol_url
      @endpoint.head(:test)
      assert_equal :test, @endpoint.validated_url
    end

    def test_head_with_empty_string_url
      @endpoint.head("")
      assert_equal "", @endpoint.validated_url
    end

    def test_head_with_nil_url
      @endpoint.head(nil)
      assert_nil @endpoint.validated_url
    end

    def test_head_raises_validation_error
      endpoint = MockEndpointWithValidationError.new
      assert_raises(ArgumentError) { endpoint.head("invalid url") }
    end

    def test_head_validation_error_message
      endpoint = MockEndpointWithValidationError.new
      error = assert_raises(ArgumentError) { endpoint.head("../path") }
      assert_equal "Invalid URL: ../path", error.message
    end

    def test_head_with_special_characters_in_url
      @endpoint.head("/path-with_special.chars_123")
      assert_equal "/path-with_special.chars_123", @endpoint.validated_url
    end

    def test_head_with_unicode_url
      @endpoint.head("/café")
      assert_equal "/café", @endpoint.validated_url
    end

    def test_head_with_long_url
      long_url = "/#{"a" * 1000}"
      @endpoint.head(long_url)
      assert_equal long_url, @endpoint.validated_url
    end

    def test_head_with_empty_options_hash
      @endpoint.head("/test", {})
      assert_equal [:head, "/test", {}], @endpoint.request_called_with
    end

    def test_head_with_nested_options
      options = { query: { nested: { key: "value" } } }
      @endpoint.head("/test", options)
      assert_equal [:head, "/test", options], @endpoint.request_called_with
    end

    def test_head_with_array_options
      options = { params: %w[a b c] }
      @endpoint.head("/test", options)
      assert_equal [:head, "/test", options], @endpoint.request_called_with
    end
  end
end
