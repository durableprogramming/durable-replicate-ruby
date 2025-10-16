# frozen_string_literal: true

require "test_helper"

module Replicate
  module Record
    module Mixins
      class StatusableTest < Minitest::Test
        class TestRecord
          include Statusable

          attr_reader :data

          def initialize(data = {})
            @data = data
          end
        end

        def test_finished_returns_true_when_succeeded
          record = TestRecord.new("status" => "succeeded")
          assert record.finished?
        end

        def test_finished_returns_true_when_failed
          record = TestRecord.new("status" => "failed")
          assert record.finished?
        end

        def test_finished_returns_true_when_canceled
          record = TestRecord.new("status" => "canceled")
          assert record.finished?
        end

        def test_finished_returns_false_when_starting
          record = TestRecord.new("status" => "starting")
          refute record.finished?
        end

        def test_finished_returns_false_when_processing
          record = TestRecord.new("status" => "processing")
          refute record.finished?
        end

        def test_finished_returns_false_when_unknown_status
          record = TestRecord.new("status" => "unknown")
          refute record.finished?
        end

        def test_running_returns_true_when_starting
          record = TestRecord.new("status" => "starting")
          assert record.running?
        end

        def test_running_returns_true_when_processing
          record = TestRecord.new("status" => "processing")
          assert record.running?
        end

        def test_running_returns_false_when_succeeded
          record = TestRecord.new("status" => "succeeded")
          refute record.running?
        end

        def test_running_returns_false_when_failed
          record = TestRecord.new("status" => "failed")
          refute record.running?
        end

        def test_running_returns_false_when_canceled
          record = TestRecord.new("status" => "canceled")
          refute record.running?
        end

        def test_running_returns_false_when_unknown_status
          record = TestRecord.new("status" => "unknown")
          refute record.running?
        end

        def test_starting_returns_true_when_starting
          record = TestRecord.new("status" => "starting")
          assert record.starting?
        end

        def test_starting_returns_false_when_processing
          record = TestRecord.new("status" => "processing")
          refute record.starting?
        end

        def test_starting_returns_false_when_succeeded
          record = TestRecord.new("status" => "succeeded")
          refute record.starting?
        end

        def test_processing_returns_true_when_processing
          record = TestRecord.new("status" => "processing")
          assert record.processing?
        end

        def test_processing_returns_false_when_starting
          record = TestRecord.new("status" => "starting")
          refute record.processing?
        end

        def test_processing_returns_false_when_succeeded
          record = TestRecord.new("status" => "succeeded")
          refute record.processing?
        end

        def test_succeeded_returns_true_when_succeeded
          record = TestRecord.new("status" => "succeeded")
          assert record.succeeded?
        end

        def test_succeeded_returns_false_when_failed
          record = TestRecord.new("status" => "failed")
          refute record.succeeded?
        end

        def test_succeeded_returns_false_when_starting
          record = TestRecord.new("status" => "starting")
          refute record.succeeded?
        end

        def test_failed_returns_true_when_failed
          record = TestRecord.new("status" => "failed")
          assert record.failed?
        end

        def test_failed_returns_false_when_succeeded
          record = TestRecord.new("status" => "succeeded")
          refute record.failed?
        end

        def test_failed_returns_false_when_starting
          record = TestRecord.new("status" => "starting")
          refute record.failed?
        end

        def test_canceled_returns_true_when_canceled
          record = TestRecord.new("status" => "canceled")
          assert record.canceled?
        end

        def test_canceled_returns_false_when_succeeded
          record = TestRecord.new("status" => "succeeded")
          refute record.canceled?
        end

        def test_canceled_returns_false_when_starting
          record = TestRecord.new("status" => "starting")
          refute record.canceled?
        end

        def test_status_description_starting
          record = TestRecord.new("status" => "starting")
          assert_equal "Starting execution", record.status_description
        end

        def test_status_description_processing
          record = TestRecord.new("status" => "processing")
          assert_equal "Processing", record.status_description
        end

        def test_status_description_succeeded
          record = TestRecord.new("status" => "succeeded")
          assert_equal "Completed successfully", record.status_description
        end

        def test_status_description_failed
          record = TestRecord.new("status" => "failed")
          assert_equal "Failed", record.status_description
        end

        def test_status_description_canceled
          record = TestRecord.new("status" => "canceled")
          assert_equal "Canceled", record.status_description
        end

        def test_status_description_nil_status
          record = TestRecord.new({})
          assert_equal "Unknown status: ", record.status_description
        end

        def test_status_description_unknown_status
          record = TestRecord.new("status" => "unknown")
          assert_equal "Unknown status: unknown", record.status_description
        end

        def test_current_status_returns_status_value
          record = TestRecord.new("status" => "succeeded")
          assert_equal "succeeded", record.send(:current_status)
        end

        def test_current_status_returns_nil_when_no_status_key
          record = TestRecord.new({})
          assert_nil record.send(:current_status)
        end

        def test_current_status_returns_nil_when_data_is_nil
          record = TestRecord.new(nil)
          assert_nil record.send(:current_status)
        end

        def test_current_status_handles_no_method_error
          record = TestRecord.new(Object.new)
          assert_nil record.send(:current_status)
        end

        def test_all_methods_return_false_when_no_data
          record = TestRecord.new(nil)
          refute record.finished?
          refute record.running?
          refute record.starting?
          refute record.processing?
          refute record.succeeded?
          refute record.failed?
          refute record.canceled?
        end

        def test_all_methods_return_false_when_data_not_hash
          record = TestRecord.new("not a hash")
          refute record.finished?
          refute record.running?
          refute record.starting?
          refute record.processing?
          refute record.succeeded?
          refute record.failed?
          refute record.canceled?
        end

        def test_status_description_with_non_hash_data
          record = TestRecord.new("not a hash")
          assert_equal "Unknown status: ", record.status_description
        end

        def test_edge_case_empty_hash
          record = TestRecord.new({})
          refute record.finished?
          refute record.running?
          refute record.starting?
          refute record.processing?
          refute record.succeeded?
          refute record.failed?
          refute record.canceled?
          assert_equal "Unknown status: ", record.status_description
        end

        def test_edge_case_nil_status_value
          record = TestRecord.new("status" => nil)
          refute record.finished?
          refute record.running?
          refute record.starting?
          refute record.processing?
          refute record.succeeded?
          refute record.failed?
          refute record.canceled?
          assert_equal "Unknown status: ", record.status_description
        end

        def test_edge_case_false_status_value
          record = TestRecord.new("status" => false)
          refute record.finished?
          refute record.running?
          refute record.starting?
          refute record.processing?
          refute record.succeeded?
          refute record.failed?
          refute record.canceled?
          assert_equal "Unknown status: false", record.status_description
        end

        def test_edge_case_numeric_status_value
          record = TestRecord.new("status" => 123)
          refute record.finished?
          refute record.running?
          refute record.starting?
          refute record.processing?
          refute record.succeeded?
          refute record.failed?
          refute record.canceled?
          assert_equal "Unknown status: 123", record.status_description
        end
      end
    end
  end
end
