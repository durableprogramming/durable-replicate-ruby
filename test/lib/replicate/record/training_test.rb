# frozen_string_literal: true

require "test_helper"

module Replicate
  module Record
    class TrainingTest < Minitest::Test
      def setup
        @client = Replicate::Client.new(api_token: "test_token")
      end

      def test_refetch_updates_training_data
        initial_data = { "id" => "training-123", "status" => "starting", "created_at" => "2023-01-01T00:00:00Z" }
        updated_response = {
          "id" => "training-123",
          "status" => "succeeded",
          "created_at" => "2023-01-01T00:00:00Z",
          "completed_at" => "2023-01-01T01:00:00Z",
          "version" => { "id" => "version-456", "model" => { "name" => "my-model" } }
        }

        stub_request(:get, "https://dreambooth-api-experimental.replicate.com/v1/trainings/training-123")
          .to_return(status: 200, body: updated_response.to_json)

        record = Replicate::Record::Training.new(@client, initial_data)
        result = record.refetch

        assert_equal "succeeded", record.status
        assert_equal "2023-01-01T01:00:00Z", record.completed_at
        assert_equal updated_response, record.data
        assert_equal record, result
      end

      def test_refetch_raises_error_on_api_failure
        initial_data = { "id" => "training-123", "status" => "starting" }

        stub_request(:get, "https://dreambooth-api-experimental.replicate.com/v1/trainings/training-123")
          .to_return(status: 404, body: { "detail" => "Training not found" }.to_json)

        record = Replicate::Record::Training.new(@client, initial_data)

        assert_raises Replicate::Error do
          record.refetch
        end
      end

      def test_version_returns_model_version_when_present
        version_data = { "id" => "version-456", "model" => { "name" => "my-model" } }
        data = { "id" => "training-123", "status" => "succeeded", "version" => version_data }

        record = Replicate::Record::Training.new(@client, data)
        version = record.version

        assert_instance_of Replicate::Record::ModelVersion, version
        assert_equal "version-456", version.id
        assert_equal @client, version.client
        assert_equal version_data, version.data
      end

      def test_version_returns_nil_when_not_present
        data = { "id" => "training-123", "status" => "processing" }

        record = Replicate::Record::Training.new(@client, data)

        assert_nil record.version
      end

      def test_version_returns_nil_when_version_is_nil
        data = { "id" => "training-123", "status" => "failed", "version" => nil }

        record = Replicate::Record::Training.new(@client, data)

        assert_nil record.version
      end

      def test_finished_returns_true_for_terminal_states
        terminal_states = %w[succeeded failed canceled]

        terminal_states.each do |status|
          record = Replicate::Record::Training.new(@client, "status" => status)
          assert record.finished?, "Expected #{status} to be finished"
        end
      end

      def test_finished_returns_false_for_non_terminal_states
        non_terminal_states = %w[starting processing]

        non_terminal_states.each do |status|
          record = Replicate::Record::Training.new(@client, "status" => status)
          refute record.finished?, "Expected #{status} to not be finished"
        end
      end

      def test_running_returns_true_for_active_states
        active_states = %w[starting processing]

        active_states.each do |status|
          record = Replicate::Record::Training.new(@client, "status" => status)
          assert record.running?, "Expected #{status} to be running"
        end
      end

      def test_running_returns_false_for_inactive_states
        inactive_states = %w[succeeded failed canceled]

        inactive_states.each do |status|
          record = Replicate::Record::Training.new(@client, "status" => status)
          refute record.running?, "Expected #{status} to not be running"
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
          record = Replicate::Record::Training.new(@client, "status" => status)
          assert record.send(method), "Expected #{method} to return true for status #{status}"

          # Test that other statuses return false
          other_statuses = status_tests.values - [status]
          other_statuses.each do |other_status|
            record = Replicate::Record::Training.new(@client, "status" => other_status)
            refute record.send(method), "Expected #{method} to return false for status #{other_status}"
          end
        end
      end

      def test_status_description_for_known_statuses
        descriptions = {
          "starting" => "Starting execution",
          "processing" => "Processing",
          "succeeded" => "Completed successfully",
          "failed" => "Failed",
          "canceled" => "Canceled"
        }

        descriptions.each do |status, expected_description|
          record = Replicate::Record::Training.new(@client, "status" => status)
          assert_equal expected_description, record.status_description
        end
      end

      def test_status_description_for_unknown_status
        record = Replicate::Record::Training.new(@client, "status" => "unknown_status")

        assert_equal "Unknown status: unknown_status", record.status_description
      end

      def test_stale_returns_false_by_default
        record = Replicate::Record::Training.new(@client, "id" => "training-123")

        refute record.stale?
      end

      def test_refetch_if_stale_calls_refetch_when_stale
        data = { "id" => "training-123", "status" => "processing" }
        record = Replicate::Record::Training.new(@client, data)

        # Mock stale? to return true
        record.stub :stale?, true do
          # Mock refetch to track calls
          refetch_called = false
          record.stub :refetch, lambda {
                                  refetch_called = true
                                  record
                                } do
            result = record.refetch_if_stale
            assert refetch_called, "Expected refetch to be called when stale"
            assert_equal record, result
          end
        end
      end

      def test_refetch_if_stale_does_not_call_refetch_when_not_stale
        data = { "id" => "training-123", "status" => "processing" }
        record = Replicate::Record::Training.new(@client, data)

        # Mock stale? to return false
        record.stub :stale?, false do
          # Mock refetch to track calls
          refetch_called = false
          record.stub :refetch, lambda {
                                  refetch_called = true
                                  record
                                } do
            result = record.refetch_if_stale
            refute refetch_called, "Expected refetch not to be called when not stale"
            assert_equal record, result
          end
        end
      end

      def test_dynamic_attribute_access
        data = {
          "id" => "training-123",
          "status" => "succeeded",
          "created_at" => "2023-01-01T00:00:00Z",
          "custom_field" => "custom_value"
        }

        record = Replicate::Record::Training.new(@client, data)

        assert_equal "training-123", record.id
        assert_equal "succeeded", record.status
        assert_equal "2023-01-01T00:00:00Z", record.created_at
        assert_equal "custom_value", record.custom_field
      end

      def test_respond_to_missing_includes_data_keys
        data = { "custom_attribute" => "value", "id" => "training-123" }
        record = Replicate::Record::Training.new(@client, data)

        assert record.respond_to?(:custom_attribute)
        assert record.respond_to?(:id)
        refute record.respond_to?(:nonexistent_attribute)
      end

      def test_to_s_returns_inspect_output
        data = { "id" => "training-123", "status" => "succeeded" }
        record = Replicate::Record::Training.new(@client, data)

        assert_equal record.inspect, record.to_s
      end

      def test_client_returns_client_instance
        record = Replicate::Record::Training.new(@client, "id" => "training-123")

        assert_equal @client, record.client
      end

      def test_data_returns_frozen_hash
        data = { "id" => "training-123", "status" => "processing" }
        record = Replicate::Record::Training.new(@client, data)

        assert_equal data, record.data
        assert record.data.frozen?
      end

      def test_equality_with_same_data
        data = { "id" => "training-123", "status" => "succeeded" }
        record1 = Replicate::Record::Training.new(@client, data)
        record2 = Replicate::Record::Training.new(@client, data)

        assert record1 == record2
      end

      def test_equality_with_different_data
        record1 = Replicate::Record::Training.new(@client, "id" => "training-1")
        record2 = Replicate::Record::Training.new(@client, "id" => "training-2")

        refute record1 == record2
      end

      def test_hash_based_on_data
        data = { "id" => "training-123" }
        record1 = Replicate::Record::Training.new(@client, data)
        record2 = Replicate::Record::Training.new(@client, data)

        assert_equal record1.hash, record2.hash
        assert_equal data.hash, record1.hash
      end

      def test_edge_case_empty_data
        record = Replicate::Record::Training.new(@client, {})

        refute record.respond_to?(:id)
        assert_raises NoMethodError do
          record.id
        end
      end

      def test_edge_case_nil_values
        record = Replicate::Record::Training.new(@client, "nil_value" => nil)

        assert_nil record.nil_value
        assert record.respond_to?(:nil_value)
      end

      def test_refetch_preserves_client_reference
        initial_data = { "id" => "training-123", "status" => "starting" }
        updated_data = { "id" => "training-123", "status" => "succeeded" }

        stub_request(:get, "https://dreambooth-api-experimental.replicate.com/v1/trainings/training-123")
          .to_return(status: 200, body: updated_data.to_json)

        record = Replicate::Record::Training.new(@client, initial_data)
        record.refetch

        assert_equal @client, record.client
      end

      def test_version_creates_model_version_with_correct_client
        version_data = { "id" => "version-456" }
        data = { "id" => "training-123", "version" => version_data }

        record = Replicate::Record::Training.new(@client, data)
        version = record.version

        assert_equal @client, version.client
      end

      def test_multiple_refetch_calls_update_data_correctly
        initial_data = { "id" => "training-123", "status" => "starting" }
        first_update = { "id" => "training-123", "status" => "processing" }
        second_update = { "id" => "training-123", "status" => "succeeded", "version" => { "id" => "v1" } }

        stub_request(:get, "https://dreambooth-api-experimental.replicate.com/v1/trainings/training-123")
          .to_return(status: 200, body: first_update.to_json).then
          .to_return(status: 200, body: second_update.to_json)

        record = Replicate::Record::Training.new(@client, initial_data)

        record.refetch
        assert_equal "processing", record.status

        record.refetch
        assert_equal "succeeded", record.status
        assert_equal "v1", record.version.id
      end

      def test_status_methods_work_with_nil_status
        record = Replicate::Record::Training.new(@client, "id" => "training-123")

        refute record.finished?
        refute record.running?
        refute record.succeeded?
        refute record.failed?
        refute record.canceled?
        refute record.starting?
        refute record.processing?
      end

      def test_status_description_with_nil_status
        record = Replicate::Record::Training.new(@client, "id" => "training-123")

        assert_equal "Unknown status: ", record.status_description
      end
    end
  end
end
