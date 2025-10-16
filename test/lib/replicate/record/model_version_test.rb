# frozen_string_literal: true

require "test_helper"

module Replicate
  module Record
    class ModelVersionTest < Minitest::Test
      def teardown
        client.webhook_url = nil
      end

      def test_predict_without_webhook_url
        response = { "completed_at" => "2022-12-07T13:57:32.018353Z", "created_at" => "2022-12-07T13:57:26.752050Z", "error" => nil, "id" => "test", "input" => { "width" => 1024, "height" => 704, "prompt" => "painting of santa clause, winter background, in the style of a beautiful christmas xmas card, painterly, royalty-free, trending on artstation, by leonid afremov", "negative_prompt" => "nsfw, nudity, child, gore, out of frame, watermark, signature, 3d render, disfigured, border, frame, stock image, text, typography, letter, digits, eyeless, pupilless, body out of frame, ugly, gross, deformed, cross-eye, blurry, bad anatomy, poorly drawn face, mutation, mutated, extra limbs, closed eyes, extra fingers, poorly drawn fingers, istockphoto watermark", "num_inference_steps" => 25 }, "logs" => "Using seed: 8654\n  0%|          | 0/25 [00:00<?, ?it/s]\n  4%|▍         | 1/25 [00:00<00:04,  5.19it/s]\n  8%|▊         | 2/25 [00:00<00:04,  5.63it/s]\n 12%|█▏        | 3/25 [00:00<00:03,  5.94it/s]\n 16%|█▌        | 4/25 [00:00<00:03,  6.09it/s]\n 20%|██        | 5/25 [00:00<00:03,  6.19it/s]\n 24%|██▍       | 6/25 [00:00<00:03,  6.24it/s]\n 28%|██▊       | 7/25 [00:01<00:02,  6.28it/s]\n 32%|███▏      | 8/25 [00:01<00:02,  6.30it/s]\n 36%|███▌      | 9/25 [00:01<00:02,  6.32it/s]\n 40%|████      | 10/25 [00:01<00:02,  6.33it/s]\n 44%|████▍     | 11/25 [00:01<00:02,  6.33it/s]\n 48%|████▊     | 12/25 [00:01<00:02,  6.34it/s]\n 52%|█████▏    | 13/25 [00:02<00:01,  6.34it/s]\n 56%|█████▌    | 14/25 [00:02<00:01,  6.34it/s]\n 60%|██████    | 15/25 [00:02<00:01,  6.34it/s]\n 64%|██████▍   | 16/25 [00:02<00:01,  6.35it/s]\n 68%|██████▊   | 17/25 [00:02<00:01,  6.35it/s]\n 72%|███████▏  | 18/25 [00:02<00:01,  6.34it/s]\n 76%|███████▌  | 19/25 [00:03<00:00,  6.34it/s]\n 80%|████████  | 20/25 [00:03<00:00,  6.34it/s]\n 84%|████████▍ | 21/25 [00:03<00:00,  6.34it/s]\n 88%|████████▊ | 22/25 [00:03<00:00,  6.34it/s]\n 92%|█████████▏| 23/25 [00:03<00:00,  6.35it/s]\n 96%|█████████▌| 24/25 [00:03<00:00,  6.35it/s]\n100%|██████████| 25/25 [00:03<00:00,  6.35it/s]\n100%|██████████| 25/25 [00:03<00:00,  6.28it/s]", "metrics" => { "predict_time" => 5.226421 }, "output" => ["https://replicate.delivery/pbxt/Wfqywp7J1M2f8ULNfM555H8DqzenDn4qNAu04kO0ZjRtcTeAC/out-0.png"], "started_at" => "2022-12-07T13:57:26.791932Z", "status" => "succeeded", "urls" => { "get" => "https://api.replicate.com/v1/predictions/test", "cancel" => "https://api.replicate.com/v1/predictions/test/cancel" }, "version" => "0827b64897df7b6e8c04625167bbb275b9db0f14ab09e2454b9824141963c966", "webhook" => nil }

        stub_request(:post, "https://api.replicate.com/v1/predictions")
          .with(body: "{\"version\":\"0827b64897df7b6e8c04625167bbb275b9db0f14ab09e2454b9824141963c966\",\"input\":{\"prompt\":\"a cute teddy bear\"}}")
          .to_return(status: 200, body: response.to_json)

        version = Replicate::Record::ModelVersion.new(client, "id" => "0827b64897df7b6e8c04625167bbb275b9db0f14ab09e2454b9824141963c966")
        prediction = version.predict(prompt: "a cute teddy bear")

        assert_equal "test", prediction.id
        assert_nil prediction.webhook
      end

      def test_predict_with_default_webhook_url
        client.webhook_url = "http://test.tld/replicate/webhook"

        response = { "completed_at" => "2022-12-07T13:57:32.018353Z", "created_at" => "2022-12-07T13:57:26.752050Z", "error" => nil, "id" => "test", "input" => { "width" => 1024, "height" => 704, "prompt" => "painting of santa clause, winter background, in the style of a beautiful christmas xmas card, painterly, royalty-free, trending on artstation, by leonid afremov", "negative_prompt" => "nsfw, nudity, child, gore, out of frame, watermark, signature, 3d render, disfigured, border, frame, stock image, text, typography, letter, digits, eyeless, pupilless, body out of frame, ugly, gross, deformed, cross-eye, blurry, bad anatomy, poorly drawn face, mutation, mutated, extra limbs, closed eyes, extra fingers, poorly drawn fingers, istockphoto watermark", "num_inference_steps" => 25 }, "logs" => "Using seed: 8654\n  0%|          | 0/25 [00:00<?, ?it/s]\n  4%|▍         | 1/25 [00:00<00:04,  5.19it/s]\n  8%|▊         | 2/25 [00:00<00:04,  5.63it/s]\n 12%|█▏        | 3/25 [00:00<00:03,  5.94it/s]\n 16%|█▌        | 4/25 [00:00<00:03,  6.09it/s]\n 20%|██        | 5/25 [00:00<00:03,  6.19it/s]\n 24%|██▍       | 6/25 [00:00<00:03,  6.24it/s]\n 28%|██▊       | 7/25 [00:01<00:02,  6.28it/s]\n 32%|███▏      | 8/25 [00:01<00:02,  6.30it/s]\n 36%|███▌      | 9/25 [00:01<00:02,  6.32it/s]\n 40%|████      | 10/25 [00:01<00:02,  6.33it/s]\n 44%|████▍     | 11/25 [00:01<00:02,  6.33it/s]\n 48%|████▊     | 12/25 [00:01<00:02,  6.34it/s]\n 52%|█████▏    | 13/25 [00:02<00:01,  6.34it/s]\n 56%|█████▌    | 14/25 [00:02<00:01,  6.34it/s]\n 60%|██████    | 15/25 [00:02<00:01,  6.34it/s]\n 64%|██████▍   | 16/25 [00:02<00:01,  6.35it/s]\n 68%|██████▊   | 17/25 [00:02<00:01,  6.35it/s]\n 72%|███████▏  | 18/25 [00:02<00:01,  6.34it/s]\n 76%|███████▌  | 19/25 [00:03<00:00,  6.34it/s]\n 80%|████████  | 20/25 [00:03<00:00,  6.34it/s]\n 84%|████████▍ | 21/25 [00:03<00:00,  6.34it/s]\n 88%|████████▊ | 22/25 [00:03<00:00,  6.34it/s]\n 92%|█████████▏| 23/25 [00:03<00:00,  6.35it/s]\n 96%|█████████▌| 24/25 [00:03<00:00,  6.35it/s]\n100%|██████████| 25/25 [00:03<00:00,  6.35it/s]\n100%|██████████| 25/25 [00:03<00:00,  6.28it/s]", "metrics" => { "predict_time" => 5.226421 }, "output" => ["https://replicate.delivery/pbxt/Wfqywp7J1M2f8ULNfM555H8DqzenDn4qNAu04kO0ZjRtcTeAC/out-0.png"], "started_at" => "2022-12-07T13:57:26.791932Z", "status" => "succeeded", "urls" => { "get" => "https://api.replicate.com/v1/predictions/test", "cancel" => "https://api.replicate.com/v1/predictions/test/cancel" }, "version" => "0827b64897df7b6e8c04625167bbb275b9db0f14ab09e2454b9824141963c966", "webhook" => "http://test.tld/replicate/webhook" }

        stub_request(:post, "https://api.replicate.com/v1/predictions")
          .with(body: "{\"version\":\"0827b64897df7b6e8c04625167bbb275b9db0f14ab09e2454b9824141963c966\",\"input\":{\"prompt\":\"a cute teddy bear\"},\"webhook\":\"http://test.tld/replicate/webhook\"}")
          .to_return(status: 200, body: response.to_json)

        version = Replicate::Record::ModelVersion.new(client, "id" => "0827b64897df7b6e8c04625167bbb275b9db0f14ab09e2454b9824141963c966")
        prediction = version.predict(prompt: "a cute teddy bear")

        assert_equal "test", prediction.id
        assert_equal "http://test.tld/replicate/webhook", prediction.webhook
      end

      def test_initialization
        data = { "id" => "test-version-id", "name" => "test-model" }
        version = Replicate::Record::ModelVersion.new(client, data)

        assert_equal client, version.client
        assert_equal data, version.data
        assert_equal "test-version-id", version.id
        assert_equal "test-model", version.name
      end

      def test_predict_with_empty_input
        response = { "id" => "empty-test", "status" => "starting" }

        stub_request(:post, "https://api.replicate.com/v1/predictions")
          .with(body: '{"version":"test-version","input":{}}')
          .to_return(status: 200, body: response.to_json)

        version = Replicate::Record::ModelVersion.new(client, "id" => "test-version")
        prediction = version.predict({})

        assert_equal "empty-test", prediction.id
      end

      def test_predict_with_complex_input
        input = {
          "prompt" => "a beautiful landscape",
          "width" => 512,
          "height" => 512,
          "num_inference_steps" => 20,
          "guidance_scale" => 7.5
        }
        response = { "id" => "complex-test", "input" => input }

        stub_request(:post, "https://api.replicate.com/v1/predictions")
          .with(body: '{"version":"test-version","input":{"prompt":"a beautiful landscape","width":512,"height":512,"num_inference_steps":20,"guidance_scale":7.5}}')
          .to_return(status: 200, body: response.to_json)

        version = Replicate::Record::ModelVersion.new(client, "id" => "test-version")
        prediction = version.predict(input)

        assert_equal "complex-test", prediction.id
        assert_equal input, prediction.input
      end

      def test_predict_with_explicit_webhook
        response = { "id" => "webhook-test", "webhook" => "http://custom.webhook" }

        stub_request(:post, "https://api.replicate.com/v1/predictions")
          .with(body: '{"version":"test-version","input":{"prompt":"test"},"webhook":"http://custom.webhook"}')
          .to_return(status: 200, body: response.to_json)

        version = Replicate::Record::ModelVersion.new(client, "id" => "test-version")
        prediction = version.predict({ "prompt" => "test" }, "http://custom.webhook")

        assert_equal "webhook-test", prediction.id
        assert_equal "http://custom.webhook", prediction.webhook
      end

      def test_predict_validation_error
        version = Replicate::Record::ModelVersion.new(client, "id" => "test-version")

        # Mock client to raise ValidationError
        mock_client = Minitest::Mock.new
        mock_client.expect :create_prediction, nil do |_params|
          raise Replicate::ValidationError, "Invalid parameters"
        end
        version.instance_variable_set(:@client, mock_client)

        assert_raises(Replicate::ValidationError) do
          version.predict({ "invalid" => "param" })
        end
        mock_client.verify
      end

      def test_predict_api_error
        version = Replicate::Record::ModelVersion.new(client, "id" => "test-version")

        # Mock client to raise APIError
        mock_client = Minitest::Mock.new
        mock_client.expect :create_prediction, nil do |_params|
          raise Replicate::APIError, "API request failed"
        end
        version.instance_variable_set(:@client, mock_client)

        assert_raises(Replicate::APIError) do
          version.predict({ "prompt" => "test" })
        end
        mock_client.verify
      end

      def test_dynamic_attributes
        data = { "id" => "attr-test", "created_at" => "2023-01-01", "cog_version" => "1.0" }
        version = Replicate::Record::ModelVersion.new(client, data)

        assert_equal "attr-test", version.id
        assert_equal "2023-01-01", version.created_at
        assert_equal "1.0", version.cog_version
        assert_raises(NoMethodError) { version.nonexistent_attribute }
      end

      def test_equality
        data1 = { "id" => "eq-test" }
        data2 = { "id" => "eq-test" }
        data3 = { "id" => "different" }

        version1 = Replicate::Record::ModelVersion.new(client, data1)
        version2 = Replicate::Record::ModelVersion.new(client, data2)
        version3 = Replicate::Record::ModelVersion.new(client, data3)

        assert_equal version1, version2
        refute_equal version1, version3
        refute_equal version1, "not a version"
      end

      def test_hash
        data = { "id" => "hash-test" }
        version1 = Replicate::Record::ModelVersion.new(client, data)
        version2 = Replicate::Record::ModelVersion.new(client, data)

        assert_equal version1.hash, version2.hash
        assert_equal version1, version2
      end

      def test_inspect_and_to_s
        data = { "id" => "inspect-test" }
        version = Replicate::Record::ModelVersion.new(client, data)

        inspect_str = version.inspect
        assert_includes inspect_str, "Replicate::Record::ModelVersion"
        assert_includes inspect_str, "@data={...}>"

        assert_equal inspect_str, version.to_s
      end
    end
  end
end
