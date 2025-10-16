# frozen_string_literal: true

require "test_helper"

module Replicate
  module Record
    class BaseTest < Minitest::Test
      def test_method_missing
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert_equal "test", record.id

        assert_raises NoMethodError do
          record.something
        end
      end

      def test_client
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert_equal "test", record.id
        assert_equal client, record.client
      end

      def test_initialize_sets_client_and_data
        params = { "id" => "test", "name" => "example" }
        record = Replicate::Record::Base.new(client, params)

        assert_equal client, record.client
        assert_equal params, record.data
        assert record.data.frozen?
      end

      def test_initialize_deep_freezes_data
        params = { "nested" => { "key" => "value" }, "array" => [1, 2, { "deep" => "freeze" }] }
        record = Replicate::Record::Base.new(client, params)

        assert record.data.frozen?
        assert record.data["nested"].frozen?
        assert record.data["array"].frozen?
        assert record.data["array"][2].frozen?
      end

      def test_deep_freeze_hash
        record = Replicate::Record::Base.new(client, {})
        frozen_hash = record.send(:deep_freeze, { "a" => 1, "b" => { "c" => 2 } })

        assert frozen_hash.frozen?
        assert frozen_hash["b"].frozen?
        assert_equal 1, frozen_hash["a"]
        assert_equal 2, frozen_hash["b"]["c"]
      end

      def test_deep_freeze_array
        record = Replicate::Record::Base.new(client, {})
        frozen_array = record.send(:deep_freeze, [1, [2, 3], { "key" => "value" }])

        assert frozen_array.frozen?
        assert frozen_array[1].frozen?
        assert frozen_array[2].frozen?
      end

      def test_deep_freeze_primitive
        record = Replicate::Record::Base.new(client, {})
        frozen_string = record.send(:deep_freeze, "test")
        frozen_int = record.send(:deep_freeze, 42)

        assert frozen_string.frozen?
        assert frozen_int.frozen?
      end

      def test_method_missing_with_existing_key
        record = Replicate::Record::Base.new(client, "id" => "test", "status" => "running")
        assert_equal "test", record.id
        assert_equal "running", record.status
      end

      def test_method_missing_with_non_existing_key
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert_raises NoMethodError do
          record.nonexistent
        end
      end

      def test_method_missing_with_args_raises_error
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert_raises NoMethodError do
          record.id("arg")
        end
      end

      def test_method_missing_with_block_raises_error
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert_raises NoMethodError do
          record.id { "block" }
        end
      end

      def test_respond_to_missing_with_existing_key
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert record.respond_to?(:id)
        assert record.respond_to?(:id)
      end

      def test_respond_to_missing_with_non_existing_key
        record = Replicate::Record::Base.new(client, "id" => "test")
        refute record.respond_to?(:nonexistent)
      end

      def test_respond_to_missing_includes_private
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert record.respond_to?(:id, true)
        refute record.respond_to?(:nonexistent, true)
      end

      def test_inspect_format
        record = Replicate::Record::Base.new(client, "id" => "test")
        expected = "#<Replicate::Record::Base:#{record.object_id} @data={...}>"
        assert_equal expected, record.inspect
      end

      def test_to_s_same_as_inspect
        record = Replicate::Record::Base.new(client, "id" => "test")
        assert_equal record.inspect, record.to_s
      end

      def test_equality_with_same_data
        data = { "id" => "test", "status" => "running" }
        record1 = Replicate::Record::Base.new(client, data)
        record2 = Replicate::Record::Base.new(client, data)

        assert record1 == record2
      end

      def test_equality_with_different_data
        record1 = Replicate::Record::Base.new(client, "id" => "test1")
        record2 = Replicate::Record::Base.new(client, "id" => "test2")

        refute record1 == record2
      end

      def test_equality_with_different_class
        record = Replicate::Record::Base.new(client, "id" => "test")
        other = "not a record"

        refute record == other
      end

      def test_hash_based_on_data
        data = { "id" => "test" }
        record1 = Replicate::Record::Base.new(client, data)
        record2 = Replicate::Record::Base.new(client, data)

        assert_equal record1.hash, record2.hash
        assert_equal data.hash, record1.hash
      end

      def test_equality
        data = { "id" => "test" }
        record1 = Replicate::Record::Base.new(client, data)
        record2 = Replicate::Record::Base.new(client, data)

        assert record1 == record2
      end

      def test_data_immutability_hash
        record = Replicate::Record::Base.new(client, "nested" => { "key" => "value" })

        assert_raises FrozenError do
          record.data["nested"]["key"] = "modified"
        end
      end

      def test_data_immutability_array
        record = Replicate::Record::Base.new(client, "array" => [1, 2, 3])

        assert_raises FrozenError do
          record.data["array"][0] = 99
        end
      end

      def test_edge_case_empty_data
        record = Replicate::Record::Base.new(client, {})

        refute record.respond_to?(:id)
        assert_raises NoMethodError do
          record.id
        end
      end

      def test_edge_case_nil_values
        record = Replicate::Record::Base.new(client, "nil_value" => nil)

        assert_nil record.nil_value
        assert record.respond_to?(:nil_value)
      end

      def test_edge_case_symbol_keys_accessible
        record = Replicate::Record::Base.new(client, "string_key" => "value")

        assert record.respond_to?(:string_key) # symbols work since to_s
        assert record.respond_to?(:string_key) # strings work
        assert_equal "value", record.string_key
      end
    end
  end
end
