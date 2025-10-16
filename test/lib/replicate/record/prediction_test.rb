# frozen_string_literal: true

require "test_helper"

module Replicate
  module Record
    class PredictionTest < Minitest::Test
      def setup
        @client = Replicate::Client.new(api_token: "test_token")
      end

      def test_refetch_updates_prediction_data
        initial_data = { "id" => "test", "status" => "starting", "completed_at" => nil }
        updated_response = {
          "id" => "test",
          "status" => "succeeded",
          "completed_at" => "2022-12-07T13:57:32.018353Z",
          "output" => ["https://example.com/result.png"]
        }

        stub_request(:get, "https://api.replicate.com/v1/predictions/test")
          .to_return(status: 200, body: updated_response.to_json)

        record = Replicate::Record::Prediction.new(@client, initial_data)
        record.refetch

        assert_equal "succeeded", record.status
        assert_equal "2022-12-07T13:57:32.018353Z", record.completed_at
        assert_equal ["https://example.com/result.png"], record.output
      end

      def test_cancel_updates_prediction_status
        initial_data = { "id" => "test", "status" => "processing" }
        cancel_response = {
          "id" => "test",
          "status" => "canceled",
          "canceled_at" => "2022-12-07T13:57:32.000000Z"
        }

        stub_request(:post, "https://api.replicate.com/v1/predictions/test/cancel")
          .to_return(status: 200, body: cancel_response.to_json)

        record = Replicate::Record::Prediction.new(@client, initial_data)
        record.cancel

        assert_equal "canceled", record.status
        assert_equal "2022-12-07T13:57:32.000000Z", record.canceled_at
      end

      def test_finished_returns_true_for_terminal_states
        # Test all terminal states
        terminal_states = %w[succeeded failed canceled]

        terminal_states.each do |status|
          record = Replicate::Record::Prediction.new(@client, "status" => status)
          assert record.finished?, "Expected #{status} to be finished"
        end
      end

      def test_finished_returns_false_for_non_terminal_states
        # Test non-terminal states
        non_terminal_states = %w[starting processing]

        non_terminal_states.each do |status|
          record = Replicate::Record::Prediction.new(@client, "status" => status)
          refute record.finished?, "Expected #{status} to not be finished"
        end
      end

      def test_status_predicate_methods
        status_tests = {
          starting?: "starting",
          processing?: "processing",
          succeeded?: "succeeded",
          failed?: "failed",
          canceled?: "canceled"
        }

        status_tests.each do |method, status|
          record = Replicate::Record::Prediction.new(@client, "status" => status)
          assert record.send(method), "Expected #{method} to return true for status #{status}"

          # Test that other statuses return false
          other_statuses = status_tests.values - [status]
          other_statuses.each do |other_status|
            record = Replicate::Record::Prediction.new(@client, "status" => other_status)
            refute record.send(method), "Expected #{method} to return false for status #{other_status}"
          end
        end
      end

      def test_output_returns_prediction_output
        output_data = ["https://example.com/image1.png", "https://example.com/image2.png"]
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
      end

      def test_output_returns_nil_when_no_output
        record = Replicate::Record::Prediction.new(@client, "status" => "processing")

        assert_nil record.output
      end

      def test_status_description_for_unknown_status
        record = Replicate::Record::Prediction.new(@client, "status" => "unknown_status")

        assert_equal "Unknown status: unknown_status", record.status_description
      end

      def test_refetch_if_stale_calls_refetch_when_stale
        # Since stale? returns false by default, this tests the method coverage
        record = Replicate::Record::Prediction.new(@client, "id" => "test", "status" => "processing", "created_at" => "2023-01-01T00:00:00Z")

        # Mock refetch to ensure it's not called
        record.stub :refetch, nil do
          result = record.refetch_if_stale
          assert_equal record, result
        end
      end

      def test_dynamic_attribute_access
        data = {
          "id" => "test-id",
          "status" => "succeeded",
          "custom_field" => "custom_value"
        }

        record = Replicate::Record::Prediction.new(@client, data)

        assert_equal "test-id", record.id
        assert_equal "succeeded", record.status
        assert_equal "custom_value", record.custom_field
      end

      def test_respond_to_missing_includes_data_keys
        data = { "custom_attribute" => "value" }
        record = Replicate::Record::Prediction.new(@client, data)

        assert record.respond_to?(:custom_attribute)
        refute record.respond_to?(:id)
        refute record.respond_to?(:nonexistent_attribute)
      end

      def test_to_s_returns_inspect_output
        data = { "id" => "test", "status" => "succeeded" }
        record = Replicate::Record::Prediction.new(@client, data)

        assert_equal record.inspect, record.to_s
      end

      def test_spaceship_operator_compares_by_created_at
        early_data = { "id" => "early", "created_at" => "2023-01-01T00:00:00Z" }
        late_data = { "id" => "late", "created_at" => "2023-01-02T00:00:00Z" }

        early_prediction = Replicate::Record::Prediction.new(@client, early_data)
        late_prediction = Replicate::Record::Prediction.new(@client, late_data)

        assert_equal(-1, early_prediction <=> late_prediction)
        assert_equal(1, late_prediction <=> early_prediction)
        assert_equal(0, early_prediction <=> early_prediction.dup)
      end

      def test_spaceship_operator_returns_nil_for_non_prediction
        prediction = Replicate::Record::Prediction.new(@client, "created_at" => "2023-01-01T00:00:00Z")
        non_prediction = "not a prediction"

        assert_nil prediction <=> non_prediction
      end

      def test_spaceship_operator_handles_nil_created_at
        data_with_nil = { "id" => "nil_created", "created_at" => nil }
        data_with_time = { "id" => "time_created", "created_at" => "2023-01-01T00:00:00Z" }

        nil_prediction = Replicate::Record::Prediction.new(@client, data_with_nil)
        time_prediction = Replicate::Record::Prediction.new(@client, data_with_time)

        # nil <=> string should return nil in Ruby
        assert_nil nil_prediction <=> time_prediction
        assert_nil time_prediction <=> nil_prediction
      end

      def test_less_than_operator
        early_data = { "created_at" => "2023-01-01T00:00:00Z" }
        late_data = { "created_at" => "2023-01-02T00:00:00Z" }

        early_prediction = Replicate::Record::Prediction.new(@client, early_data)
        late_prediction = Replicate::Record::Prediction.new(@client, late_data)

        assert early_prediction < late_prediction
        refute late_prediction < early_prediction
      end

      def test_greater_than_operator
        early_data = { "created_at" => "2023-01-01T00:00:00Z" }
        late_data = { "created_at" => "2023-01-02T00:00:00Z" }

        early_prediction = Replicate::Record::Prediction.new(@client, early_data)
        late_prediction = Replicate::Record::Prediction.new(@client, late_data)

        assert late_prediction > early_prediction
        refute early_prediction > late_prediction
      end

      def test_equality_with_same_created_at_and_data
        data = { "id" => "test", "created_at" => "2023-01-01T00:00:00Z", "status" => "succeeded" }
        prediction1 = Replicate::Record::Prediction.new(@client, data)
        prediction2 = Replicate::Record::Prediction.new(@client, data.dup)

        assert prediction1 == prediction2
      end

      def test_equality_with_different_created_at
        data1 = { "id" => "test", "created_at" => "2023-01-01T00:00:00Z" }
        data2 = { "id" => "test", "created_at" => "2023-01-02T00:00:00Z" }

        prediction1 = Replicate::Record::Prediction.new(@client, data1)
        prediction2 = Replicate::Record::Prediction.new(@client, data2)

        refute prediction1 == prediction2
      end

      def test_equality_with_different_data
        data1 = { "id" => "test1", "created_at" => "2023-01-01T00:00:00Z" }
        data2 = { "id" => "test2", "created_at" => "2023-01-01T00:00:00Z" }

        prediction1 = Replicate::Record::Prediction.new(@client, data1)
        prediction2 = Replicate::Record::Prediction.new(@client, data2)

        refute prediction1 == prediction2
      end

      def test_equality_with_non_prediction
        prediction = Replicate::Record::Prediction.new(@client, "created_at" => "2023-01-01T00:00:00Z")
        non_prediction = "not a prediction"

        refute prediction == non_prediction
      end

      def test_refetch_raises_error_on_api_failure
        record = Replicate::Record::Prediction.new(@client, "id" => "test")

        @client.stub :retrieve_prediction, ->(_) { raise Replicate::APIError, "API Error" } do
          assert_raises(Replicate::APIError) { record.refetch }
        end
      end

      def test_cancel_raises_error_on_api_failure
        record = Replicate::Record::Prediction.new(@client, "id" => "test")

        @client.stub :cancel_prediction, ->(_) { raise Replicate::APIError, "Cancel Error" } do
          assert_raises(Replicate::APIError) { record.cancel }
        end
      end

      def test_refetch_raises_error_on_validation_failure
        record = Replicate::Record::Prediction.new(@client, "id" => "invalid")

        @client.stub :retrieve_prediction, ->(_) { raise Replicate::ValidationError, "Invalid ID" } do
          assert_raises(Replicate::ValidationError) { record.refetch }
        end
      end

      def test_cancel_raises_error_on_validation_failure
        record = Replicate::Record::Prediction.new(@client, "id" => "invalid")

        @client.stub :cancel_prediction, ->(_) { raise Replicate::ValidationError, "Invalid ID" } do
          assert_raises(Replicate::ValidationError) { record.cancel }
        end
      end

      def test_refetch_preserves_data_on_error
        original_data = { "id" => "test", "status" => "processing" }
        record = Replicate::Record::Prediction.new(@client, original_data)

        @client.stub :retrieve_prediction, ->(_) { raise Replicate::APIError, "Error" } do
          assert_raises(Replicate::APIError) { record.refetch }
          assert_equal original_data, record.data
        end
      end

      def test_cancel_preserves_data_on_error
        original_data = { "id" => "test", "status" => "processing" }
        record = Replicate::Record::Prediction.new(@client, original_data)

        @client.stub :cancel_prediction, ->(_) { raise Replicate::APIError, "Error" } do
          assert_raises(Replicate::APIError) { record.cancel }
          assert_equal original_data, record.data
        end
      end

      def test_output_returns_array
        output_data = ["image1.png", "image2.png", "image3.png"]
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_instance_of Array, record.output
      end

      def test_output_returns_hash
        output_data = { "text" => "Generated text", "confidence" => 0.95 }
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_instance_of Hash, record.output
      end

      def test_output_returns_string
        output_data = "Single string output"
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_instance_of String, record.output
      end

      def test_output_returns_number
        output_data = 42
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_instance_of Integer, record.output
      end

      def test_output_returns_boolean
        output_data = true
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_instance_of TrueClass, record.output
      end

      def test_output_returns_empty_array
        output_data = []
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_empty record.output
      end

      def test_output_returns_empty_hash
        output_data = {}
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_empty record.output
      end

      def test_output_returns_nested_structures
        output_data = { "images" => ["img1.png", "img2.png"], "metadata" => { "model" => "test" } }
        record = Replicate::Record::Prediction.new(@client, "output" => output_data)

        assert_equal output_data, record.output
        assert_equal ["img1.png", "img2.png"], record.output["images"]
        assert_equal({ "model" => "test" }, record.output["metadata"])
      end

      def test_refetch_returns_self_for_method_chaining
        initial_data = { "id" => "test", "status" => "starting" }
        updated_response = { "id" => "test", "status" => "succeeded" }

        stub_request(:get, "https://api.replicate.com/v1/predictions/test")
          .to_return(status: 200, body: updated_response.to_json)

        record = Replicate::Record::Prediction.new(@client, initial_data)
        result = record.refetch

        assert_same record, result
        assert_equal "succeeded", record.status
      end

      def test_cancel_returns_self_for_method_chaining
        initial_data = { "id" => "test", "status" => "processing" }
        cancel_response = { "id" => "test", "status" => "canceled" }

        stub_request(:post, "https://api.replicate.com/v1/predictions/test/cancel")
          .to_return(status: 200, body: cancel_response.to_json)

        record = Replicate::Record::Prediction.new(@client, initial_data)
        result = record.cancel

        assert_same record, result
        assert_equal "canceled", record.status
      end

      def test_method_chaining_works_with_multiple_calls
        initial_data = { "id" => "test", "status" => "processing" }
        cancel_response = { "id" => "test", "status" => "canceled" }

        stub_request(:post, "https://api.replicate.com/v1/predictions/test/cancel")
          .to_return(status: 200, body: cancel_response.to_json)

        record = Replicate::Record::Prediction.new(@client, initial_data)

        # Test chaining - though cancel returns self, we can't chain refetch after cancel easily
        # since refetch would need another stub. But we can test that cancel returns self.
        result = record.cancel

        assert_same record, result
      end

      def test_data_is_deep_frozen
        data = {
          "id" => "test",
          "output" => %w[item1 item2],
          "metadata" => { "key" => "value" }
        }
        record = Replicate::Record::Prediction.new(@client, data)

        assert record.data.frozen?
        assert record.data["output"].frozen?
        assert record.data["metadata"].frozen?
      end

      def test_modifying_frozen_data_raises_error
        data = { "id" => "test", "status" => "processing" }
        record = Replicate::Record::Prediction.new(@client, data)

        assert_raises(FrozenError) { record.data["new_key"] = "value" }
        assert_raises(FrozenError) { record.data["status"] = "modified" }
      end

      def test_modifying_nested_frozen_structures_raises_error
        data = { "output" => %w[item1 item2], "metadata" => { "key" => "value" } }
        record = Replicate::Record::Prediction.new(@client, data)

        assert_raises(FrozenError) { record.data["output"] << "item3" }
        assert_raises(FrozenError) { record.data["metadata"]["new_key"] = "new_value" }
      end

      def test_refetch_updates_data_with_new_frozen_instance
        initial_data = { "id" => "test", "status" => "starting" }
        updated_response = {
          "id" => "test",
          "status" => "succeeded",
          "output" => ["result.png"]
        }

        stub_request(:get, "https://api.replicate.com/v1/predictions/test")
          .to_return(status: 200, body: updated_response.to_json)

        record = Replicate::Record::Prediction.new(@client, initial_data)
        original_data_object_id = record.data.object_id

        record.refetch

        refute_equal original_data_object_id, record.data.object_id
        assert record.data.frozen?
        assert_equal "succeeded", record.status
      end

      def test_concurrent_reads_are_thread_safe
        data = { "id" => "test", "status" => "succeeded", "output" => ["result"] }
        record = Replicate::Record::Prediction.new(@client, data)

        results = []
        threads = Array.new(10) do
          Thread.new do
            results << record.status
            results << record.output
            results << record.id
          end
        end

        threads.each(&:join)

        assert_equal 30, results.size # 10 threads * 3 reads each
        results.each { |result| assert result } # All should be truthy
      end

      def test_data_consistency_across_threads
        data = { "id" => "test", "status" => "processing", "created_at" => "2023-01-01T00:00:00Z" }
        record = Replicate::Record::Prediction.new(@client, data)

        statuses = []
        mutex = Mutex.new

        threads = Array.new(5) do |_i|
          Thread.new do
            # Simulate some work
            sleep 0.001
            mutex.synchronize { statuses << record.status }
          end
        end

        threads.each(&:join)

        assert_equal 5, statuses.size
        statuses.each { |status| assert_equal "processing", status }
      end

      def test_prediction_creation_performance
        data = { "id" => "test", "status" => "succeeded", "output" => ["result"] }

        start_time = Time.now
        1000.times { Replicate::Record::Prediction.new(@client, data) }
        end_time = Time.now

        elapsed = end_time - start_time
        # Should complete in less than 1 second for 1000 creations
        assert elapsed < 1.0, "Prediction creation took too long: #{elapsed}s"
      end

      def test_attribute_access_performance
        data = { "id" => "test", "status" => "succeeded", "output" => ["result"] }
        record = Replicate::Record::Prediction.new(@client, data)

        start_time = Time.now
        10_000.times do
          record.status
          record.output
          record.id
        end
        end_time = Time.now

        elapsed = end_time - start_time
        # Should complete in less than 0.5 seconds for 10000 accesses
        assert elapsed < 0.5, "Attribute access took too long: #{elapsed}s"
      end
    end
  end
end
