# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Methods for Dreambooth model training on Replicate
    module Training
      # Retrieves a training job by its ID
      #
      # @param id [String] The training job ID
      # @return [Replicate::Record::Training] The training instance
      # @raise [Replicate::Error] If the API request fails or training is not found
      # @see https://replicate.com/blog/dreambooth-api
      # @example Retrieve a training job
      #   training = client.retrieve_training("training-123")
      def retrieve_training(id)
        response = dreambooth_endpoint.get("trainings/#{id}")
        Replicate::Record::Training.new(self, response)
      end

      # Creates a new Dreambooth training job
      #
      # @param params [Hash] The training parameters
      # @option params [Hash] :input The training input parameters (instance_prompt, class_prompt, etc.)
      # @option params [String] :model The destination model identifier (username/model-name format)
      # @option params [String] :webhook Optional webhook URL for completion notifications
      # @return [Replicate::Record::Training] The created training instance
      # @raise [Replicate::Error] If the API request fails or parameters are invalid
      # @see https://replicate.com/blog/dreambooth-api
      # @example Create a training job
      #   training = client.create_training(
      #     input: {
      #       instance_prompt: "photo of zwx person",
      #       class_prompt: "photo of person",
      #       instance_data: upload.serving_url,
      #       max_train_steps: 2000
      #     },
      #     model: "myusername/my-model"
      #   )
      def create_training(params)
        params[:webhook] ||= webhook_url
        response = dreambooth_endpoint.post("trainings", params)
        Replicate::Record::Training.new(self, response)
      end
    end
  end
end
