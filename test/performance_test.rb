# frozen_string_literal: true

require "test_helper"
require "benchmark"

class PerformanceTest < Minitest::Test
  def test_client_initialization_performance
    skip "Performance test - run with: bundle exec rake benchmark"

    # Test that client initialization is reasonably fast
    time = Benchmark.realtime do
      100.times do
        Replicate::Client.new(api_token: "test_token")
      end
    end

    # Should complete 100 initializations in under 1 second
    assert time < 1.0, "Client initialization took #{time} seconds for 100 instances"
  end

  def test_record_creation_performance
    skip "Performance test - run with: bundle exec rake benchmark"

    test_data = {
      "id" => "test_prediction_id",
      "status" => "succeeded",
      "input" => { "prompt" => "test prompt" },
      "output" => ["test output"],
      "created_at" => "2023-01-01T00:00:00Z",
      "started_at" => "2023-01-01T00:00:01Z",
      "completed_at" => "2023-01-01T00:00:02Z"
    }

    time = Benchmark.realtime do
      1000.times do
        Replicate::Record::Base.new(nil, test_data)
      end
    end

    # Should complete 1000 record creations in under 0.5 seconds
    assert time < 0.5, "Record creation took #{time} seconds for 1000 instances"
  end

  def test_memory_usage
    skip "Memory test - requires derailed_benchmarks gem"

    # This would require additional setup with derailed_benchmarks
    # For now, just ensure basic functionality doesn't cause obvious memory issues
    initial_objects = ObjectSpace.count_objects

    100.times do
      client = Replicate::Client.new(api_token: "test_token")
      Replicate::Record::Base.new(client, { "id" => "test" })
    end

    final_objects = ObjectSpace.count_objects

    # Basic sanity check - not a rigorous memory test
    created_objects = final_objects[:T_OBJECT] - initial_objects[:T_OBJECT]
    assert created_objects < 10_000, "Too many objects created: #{created_objects}"
  end
end
