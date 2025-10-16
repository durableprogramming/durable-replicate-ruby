# frozen_string_literal: true

require "test_helper"

module Replicate
  module Record
    class ModelTest < Minitest::Test
      def setup
        @client = Replicate::Client.new(api_token: "test_token")
      end

      def test_initialize_converts_latest_version_to_model_version
        latest_version_data = { "id" => "version-123", "created_at" => "2023-01-01T00:00:00Z" }
        params = {
          "url" => "https://replicate.com/stability-ai/stable-diffusion",
          "owner" => "stability-ai",
          "name" => "stable-diffusion",
          "description" => "A stable diffusion model",
          "latest_version" => latest_version_data
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_instance_of Replicate::Record::ModelVersion, model.latest_version
        assert_equal "version-123", model.latest_version.id
        assert_equal "2023-01-01T00:00:00Z", model.latest_version.created_at
      end

      def test_initialize_with_nil_latest_version
        params = {
          "url" => "https://replicate.com/stability-ai/stable-diffusion",
          "owner" => "stability-ai",
          "name" => "stable-diffusion",
          "description" => "A stable diffusion model",
          "latest_version" => nil
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_nil model.latest_version
      end

      def test_initialize_without_latest_version_key
        params = {
          "url" => "https://replicate.com/stability-ai/stable-diffusion",
          "owner" => "stability-ai",
          "name" => "stable-diffusion",
          "description" => "A stable diffusion model"
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_nil model.latest_version
      end

      def test_latest_version_returns_model_version_instance
        latest_version_data = { "id" => "version-456", "cog_version" => "0.3.0" }
        params = { "latest_version" => latest_version_data }

        model = Replicate::Record::Model.new(@client, params)

        assert_instance_of Replicate::Record::ModelVersion, model.latest_version
        assert_equal "version-456", model.latest_version.id
        assert_equal "0.3.0", model.latest_version.cog_version
      end

      def test_versions_lazy_loads_all_versions
        model_params = {
          "owner" => "stability-ai",
          "name" => "stable-diffusion",
          "latest_version" => { "id" => "latest" }
        }

        versions_data = [
          { "id" => "version-1", "created_at" => "2023-01-01T00:00:00Z" },
          { "id" => "version-2", "created_at" => "2023-01-02T00:00:00Z" }
        ]

        # Mock the client.retrieve_model call
        @client.stub(:retrieve_model, versions_data.map { |v| Replicate::Record::ModelVersion.new(@client, v) }) do
          model = Replicate::Record::Model.new(@client, model_params)

          # First call should load versions
          versions = model.versions
          assert_equal 2, versions.length
          assert_instance_of Replicate::Record::ModelVersion, versions.first
          assert_equal "version-1", versions.first.id
          assert_equal "version-2", versions.last.id

          # Second call should return cached versions
          versions2 = model.versions
          assert_equal versions.object_id, versions2.object_id
        end
      end

      def test_versions_calls_client_with_correct_identifier
        model_params = {
          "owner" => "openai",
          "name" => "dall-e",
          "latest_version" => { "id" => "latest" }
        }

        expected_identifier = "openai/dall-e"
        versions_data = [{ "id" => "version-1" }]

        # Use a simple approach - just check that the method is called
        called_with = nil
        @client.define_singleton_method(:retrieve_model) do |model, version: :latest|
          called_with = [model, version]
          versions_data.map { |v| Replicate::Record::ModelVersion.new(@client, v) }
        end

        model = Replicate::Record::Model.new(@client, model_params)
        model.versions

        assert_equal [expected_identifier, :all], called_with
      ensure
        # Restore original method
        if @client.singleton_class.method_defined?(:retrieve_model)
          @client.singleton_class.remove_method(:retrieve_model)
        end
      end

      def test_identifier_returns_owner_slash_name
        params = {
          "owner" => "stability-ai",
          "name" => "stable-diffusion",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal "stability-ai/stable-diffusion", model.identifier
      end

      def test_identifier_with_special_characters
        params = {
          "owner" => "user.name",
          "name" => "model-name.v1",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal "user.name/model-name.v1", model.identifier
      end

      def test_identifier_with_missing_owner
        params = {
          "name" => "stable-diffusion",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal "/stable-diffusion", model.identifier
      end

      def test_identifier_with_missing_name
        params = {
          "owner" => "stability-ai",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal "stability-ai/", model.identifier
      end

      def test_identifier_with_nil_owner_and_name
        params = {
          "owner" => nil,
          "name" => nil,
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal "/", model.identifier
      end

      def test_dynamic_attribute_access_inherited_from_base
        params = {
          "url" => "https://replicate.com/test/model",
          "owner" => "test",
          "name" => "model",
          "description" => "Test model",
          "visibility" => "public",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal "https://replicate.com/test/model", model.url
        assert_equal "test", model.owner
        assert_equal "model", model.name
        assert_equal "Test model", model.description
        assert_equal "public", model.visibility
      end

      def test_respond_to_missing_inherited_from_base
        params = {
          "custom_field" => "value",
          "url" => "https://example.com",
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert model.respond_to?(:custom_field)
        assert model.respond_to?(:url)
        assert model.respond_to?(:owner)
        assert model.respond_to?(:name)
        refute model.respond_to?(:nonexistent)
      end

      def test_equality_inherited_from_base
        params1 = {
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "v1" }
        }
        params2 = {
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "v1" }
        }
        params3 = {
          "owner" => "different",
          "name" => "model",
          "latest_version" => { "id" => "v1" }
        }

        model1 = Replicate::Record::Model.new(@client, params1)
        model2 = Replicate::Record::Model.new(@client, params2)
        model3 = Replicate::Record::Model.new(@client, params3)

        assert model1 == model2
        refute model1 == model3
      end

      def test_hash_inherited_from_base
        params = {
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "v1" }
        }

        model1 = Replicate::Record::Model.new(@client, params)
        model2 = Replicate::Record::Model.new(@client, params)

        assert_equal model1.hash, model2.hash
      end

      def test_inspect_inherited_from_base
        params = {
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        expected_pattern = /#<Replicate::Record::Model:\d+ @data=\{...\}>/
        assert_match expected_pattern, model.inspect
      end

      def test_to_s_inherited_from_base
        params = {
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal model.inspect, model.to_s
      end

      def test_data_immutability_inherited_from_base
        params = {
          "nested" => { "key" => "value" },
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_raises FrozenError do
          model.data["nested"]["key"] = "modified"
        end
      end

      def test_versions_handles_empty_array
        model_params = {
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "latest" }
        }

        @client.stub :retrieve_model, [] do
          model = Replicate::Record::Model.new(@client, model_params)

          versions = model.versions
          assert_empty versions
          assert_instance_of Array, versions
        end
      end

      def test_versions_handles_single_version
        model_params = {
          "owner" => "test",
          "name" => "model",
          "latest_version" => { "id" => "latest" }
        }

        version_data = { "id" => "only-version", "created_at" => "2023-01-01T00:00:00Z" }

        @client.stub :retrieve_model, [Replicate::Record::ModelVersion.new(@client, version_data)] do
          model = Replicate::Record::Model.new(@client, model_params)

          versions = model.versions
          assert_equal 1, versions.length
          assert_equal "only-version", versions.first.id
        end
      end

      def test_multiple_model_instances_independent_versions
        params1 = {
          "owner" => "owner1",
          "name" => "model1",
          "latest_version" => { "id" => "v1" }
        }
        params2 = {
          "owner" => "owner2",
          "name" => "model2",
          "latest_version" => { "id" => "v2" }
        }

        versions1 = [{ "id" => "version-1" }]
        versions2 = [{ "id" => "version-a" }, { "id" => "version-b" }]

        call_count = 0
        @client.define_singleton_method(:retrieve_model) do |model, version: :latest|
          _version = version # avoid unused variable warning
          call_count += 1
          case model
          when "owner1/model1"
            versions1.map { |v| Replicate::Record::ModelVersion.new(@client, v) }
          when "owner2/model2"
            versions2.map { |v| Replicate::Record::ModelVersion.new(@client, v) }
          end
        end

        model1 = Replicate::Record::Model.new(@client, params1)
        model2 = Replicate::Record::Model.new(@client, params2)

        # Access versions for both models
        model1.versions
        model2.versions

        # Each should have made its own call
        assert_equal 2, call_count

        # And cached independently
        model1.versions
        model2.versions
        assert_equal 2, call_count # No additional calls
      ensure
        # Restore original method
        if @client.singleton_class.method_defined?(:retrieve_model)
          @client.singleton_class.remove_method(:retrieve_model)
        end
      end

      def test_edge_case_empty_params
        model = Replicate::Record::Model.new(@client, {})

        assert_nil model.latest_version
        assert_equal "/", model.identifier
      end

      def test_edge_case_numeric_owner_name
        params = {
          "owner" => 123,
          "name" => 456,
          "latest_version" => { "id" => "latest" }
        }

        model = Replicate::Record::Model.new(@client, params)

        assert_equal "123/456", model.identifier
      end

      def test_client_assignment_inherited_from_base
        params = { "latest_version" => { "id" => "latest" } }
        model = Replicate::Record::Model.new(@client, params)

        assert_equal @client, model.client
      end
    end
  end
end
