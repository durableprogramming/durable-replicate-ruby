# frozen_string_literal: true

require "test_helper"

module Replicate
  module Record
    class UploadTest < Minitest::Test
      def setup
        @client = client
        @upload_data = {
          "upload_url" => "https://example.com/upload",
          "serving_url" => "https://example.com/serving"
        }
        @upload = Replicate::Record::Upload.new(@client, @upload_data)
      end

      def test_attach_calls_client_update_upload
        mock_response = Object.new
        mock_client = Minitest::Mock.new
        mock_client.expect :update_upload, mock_response, [@upload_data["upload_url"], "/path/to/file.zip"]
        @upload.instance_variable_set(:@client, mock_client)

        result = @upload.attach("/path/to/file.zip")

        assert_same mock_response, result
        mock_client.verify
      end

      def test_upload_url_returns_upload_url_from_data
        assert_equal "https://example.com/upload", @upload.upload_url
      end

      def test_serving_url_returns_serving_url_from_data
        assert_equal "https://example.com/serving", @upload.serving_url
      end

      def test_inherits_from_base
        assert_kind_of Replicate::Record::Base, @upload
      end

      def test_method_missing_for_data_keys
        upload_with_extra_data = Replicate::Record::Upload.new(@client, @upload_data.merge("id" => "test_id"))
        assert_equal "test_id", upload_with_extra_data.id
      end

      def test_attach_with_nil_path
        assert_raises Replicate::ValidationError do
          @upload.attach(nil)
        end
      end

      def test_attach_with_empty_path
        assert_raises Replicate::ValidationError do
          @upload.attach("")
        end
      end

      def test_upload_url_with_missing_key
        upload_without_url = Replicate::Record::Upload.new(@client, {})
        assert_nil upload_without_url.upload_url
      end

      def test_serving_url_with_missing_key
        upload_without_url = Replicate::Record::Upload.new(@client, {})
        assert_nil upload_without_url.serving_url
      end

      def test_attach_propagates_client_errors
        mock_client = Minitest::Mock.new
        mock_client.expect :update_upload, nil do |_url, _path|
          raise Replicate::Error, "Upload failed"
        end
        @upload.instance_variable_set(:@client, mock_client)

        assert_raises Replicate::Error do
          @upload.attach("/path/to/file.zip")
        end
        mock_client.verify
      end

      def test_data_immutability
        assert @upload.data.frozen?
      end

      def test_equality_with_same_data
        upload2 = Replicate::Record::Upload.new(@client, @upload_data)
        assert @upload == upload2
      end

      def test_equality_with_different_data
        upload2 = Replicate::Record::Upload.new(@client, @upload_data.merge("upload_url" => "different"))
        refute @upload == upload2
      end

      def test_hash_based_on_data
        upload2 = Replicate::Record::Upload.new(@client, @upload_data)
        assert_equal @upload.hash, upload2.hash
      end

      def test_inspect_format
        expected = "#<Replicate::Record::Upload:#{@upload.object_id} @data={...}>"
        assert_equal expected, @upload.inspect
      end

      def test_to_s_same_as_inspect
        assert_equal @upload.inspect, @upload.to_s
      end

      def test_respond_to_missing_for_data_keys
        assert @upload.respond_to?(:upload_url)
        assert @upload.respond_to?(:serving_url)
      end

      def test_respond_to_missing_for_nonexistent_keys
        refute @upload.respond_to?(:nonexistent)
      end

      def test_case_equality
        upload2 = Replicate::Record::Upload.new(@client, @upload_data)
        assert @upload == upload2
      end

      def test_attach_with_valid_fixture_file
        fixture_path = File.join(__dir__, "../../fixtures/data.zip")
        mock_response = Object.new
        mock_client = Minitest::Mock.new
        mock_client.expect :update_upload, mock_response, [@upload_data["upload_url"], fixture_path]
        @upload.instance_variable_set(:@client, mock_client)

        result = @upload.attach(fixture_path)

        assert_same mock_response, result
        mock_client.verify
      end

      def test_upload_url_with_special_characters
        special_data = @upload_data.merge("upload_url" => "https://example.com/upload?param=value&other=test")
        upload = Replicate::Record::Upload.new(@client, special_data)

        assert_equal "https://example.com/upload?param=value&other=test", upload.upload_url
      end

      def test_serving_url_with_special_characters
        special_data = @upload_data.merge("serving_url" => "https://example.com/serving?param=value&other=test")
        upload = Replicate::Record::Upload.new(@client, special_data)

        assert_equal "https://example.com/serving?param=value&other=test", upload.serving_url
      end

      def test_attach_with_relative_path
        mock_response = Object.new
        mock_client = Minitest::Mock.new
        mock_client.expect :update_upload, mock_response, [@upload_data["upload_url"], "relative/path/file.zip"]
        @upload.instance_variable_set(:@client, mock_client)

        result = @upload.attach("relative/path/file.zip")

        assert_same mock_response, result
        mock_client.verify
      end

      def test_client_accessor
        assert_equal @client, @upload.client
      end

      def test_data_accessor
        assert_equal @upload_data, @upload.data
      end
    end
  end
end
