# frozen_string_literal: true

require "test_helper"
require "replicate/endpoint"

module Replicate
  class EndpointAgentTest < Minitest::Test
    class MockEndpoint
      include Replicate::EndpointAgent

      attr_accessor :configure_agent_called

      def configure_agent
        @configure_agent_called = true
        :mock_faraday_connection
      end
    end

    def setup
      @endpoint = MockEndpoint.new
    end

    def test_agent_calls_configure_agent_on_first_call
      result = @endpoint.agent
      assert @endpoint.configure_agent_called
      assert_equal :mock_faraday_connection, result
    end

    def test_agent_memoizes_result
      @endpoint.agent
      @endpoint.configure_agent_called = false # Reset to check if called again
      result = @endpoint.agent
      refute @endpoint.configure_agent_called
      assert_equal :mock_faraday_connection, result
    end

    def test_agent_returns_same_object_on_multiple_calls
      first_call = @endpoint.agent
      second_call = @endpoint.agent
      assert_same first_call, second_call
    end

    def test_agent_handles_nil_configure_agent_result
      @endpoint.define_singleton_method(:configure_agent) { nil }
      result = @endpoint.agent
      assert_nil result
    end

    def test_agent_handles_exception_in_configure_agent
      @endpoint.define_singleton_method(:configure_agent) { raise StandardError, "Configuration failed" }
      assert_raises(StandardError) { @endpoint.agent }
    end

    def test_agent_with_custom_configure_agent
      @endpoint.define_singleton_method(:configure_agent) { { custom: "connection" } }
      result = @endpoint.agent
      assert_equal({ custom: "connection" }, result)
    end

    def test_agent_instance_variable_set_correctly
      @endpoint.agent
      assert_equal :mock_faraday_connection, @endpoint.instance_variable_get(:@agent)
    end

    def test_agent_does_not_call_configure_agent_if_already_set
      @endpoint.instance_variable_set(:@agent, :pre_set_connection)
      result = @endpoint.agent
      refute @endpoint.configure_agent_called
      assert_equal :pre_set_connection, result
    end

    def test_agent_with_false_configure_agent_result
      @endpoint.define_singleton_method(:configure_agent) { false }
      result = @endpoint.agent
      assert_equal false, result
    end

    def test_agent_with_empty_hash_configure_agent_result
      @endpoint.define_singleton_method(:configure_agent) { {} }
      result = @endpoint.agent
      assert_equal({}, result)
    end

    def test_agent_with_array_configure_agent_result
      @endpoint.define_singleton_method(:configure_agent) { [1, 2, 3] }
      result = @endpoint.agent
      assert_equal([1, 2, 3], result)
    end

    def test_agent_with_string_configure_agent_result
      @endpoint.define_singleton_method(:configure_agent) { "connection_string" }
      result = @endpoint.agent
      assert_equal("connection_string", result)
    end

    def test_agent_with_numeric_configure_agent_result
      @endpoint.define_singleton_method(:configure_agent) { 42 }
      result = @endpoint.agent
      assert_equal(42, result)
    end

    def test_agent_thread_safety_basic
      # Basic test for thread safety - in a real scenario, use mutex or similar
      threads = []
      results = []
      10.times do
        threads << Thread.new do
          results << @endpoint.agent
        end
      end
      threads.each(&:join)
      # All results should be the same object
      assert results.uniq.size == 1
      assert_same results.first, results.last
    end

    def test_agent_with_configure_agent_returning_proc
      proc_connection = proc { "lazy_connection" }
      @endpoint.define_singleton_method(:configure_agent) { proc_connection }
      result = @endpoint.agent
      assert_equal proc_connection, result
    end

    def test_agent_with_configure_agent_returning_lambda
      lambda_connection = -> { "lambda_connection" }
      @endpoint.define_singleton_method(:configure_agent) { lambda_connection }
      result = @endpoint.agent
      assert_equal lambda_connection, result
    end

    def test_agent_behavior_after_exception_retry
      call_count = 0
      @endpoint.define_singleton_method(:configure_agent) do
        call_count += 1
        raise StandardError, "Temporary failure" if call_count == 1

        :recovered_connection
      end

      assert_raises(StandardError) { @endpoint.agent }
      result = @endpoint.agent # Should succeed on second call
      assert_equal :recovered_connection, result
    end

    def test_agent_with_configure_agent_returning_faraday_like_object
      faraday_mock = Object.new
      def faraday_mock.get; end
      def faraday_mock.post; end
      @endpoint.define_singleton_method(:configure_agent) { faraday_mock }
      result = @endpoint.agent
      assert_same faraday_mock, result
      assert_respond_to result, :get
      assert_respond_to result, :post
    end

    def test_agent_memoization_with_multiple_instances
      endpoint2 = MockEndpoint.new
      endpoint2.define_singleton_method(:configure_agent) { :different_connection }
      result1 = @endpoint.agent
      result2 = endpoint2.agent
      refute_same result1, result2
      assert_equal :mock_faraday_connection, result1
      assert_equal :different_connection, result2
    end

    def test_agent_with_configure_agent_taking_time
      start_time = Time.now
      @endpoint.define_singleton_method(:configure_agent) do
        sleep 0.01 # Simulate some configuration time
        :slow_connection
      end
      result = @endpoint.agent
      end_time = Time.now
      assert end_time - start_time >= 0.01
      assert_equal :slow_connection, result
    end
  end
end
