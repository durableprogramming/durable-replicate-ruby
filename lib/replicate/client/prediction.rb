# frozen_string_literal: true

module Replicate
  module ClientMixins
    # Methods for interacting with Replicate predictions
    module Prediction
      require_relative "prediction/retrieve_prediction"
      require_relative "prediction/list_predictions"
      require_relative "prediction/create_prediction"
      require_relative "prediction/cancel_prediction"
      require_relative "prediction/validate_prediction_id"
      require_relative "prediction/validate_version_param"
      require_relative "prediction/validate_input_param"
      require_relative "prediction/validate_webhook_param"
      require_relative "prediction/validate_prediction_params"
      require_relative "prediction/normalize_and_coerce_input"
      require_relative "prediction/coerce_input_value"
      require_relative "prediction/valid_url"
    end
  end
end
