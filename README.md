# Durable Replicate Ruby Client

A comprehensive Ruby client for [Replicate](https://replicate.com/), enabling you to run machine learning models, manage predictions, and perform custom model training through Ruby code.

This is a fork of the [replicate-ruby](https://github.com/dreamingtulpa/replicate-ruby) gem.

## Table of Contents

- [Installation](#installation)
- [Requirements](#requirements)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Models and Predictions](#models-and-predictions)
  - [Dreambooth Training](#dreambooth-training)
- [API Reference](#api-reference)
- [Error Handling](#error-handling)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'durable-replicate-ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install durable-replicate-ruby
```

## Requirements

- Ruby >= 2.6.0
- A [Replicate API token](https://replicate.com/account) (get one from your account settings)

## Configuration

First, obtain your API token from [replicate.com/account](https://replicate.com/account).

### Environment Variables

You can configure the client using environment variables:

```bash
export REPLICATE_API_TOKEN="your_api_token_here"
export REPLICATE_WEBHOOK_URL="https://your-app.com/webhooks/replicate" # optional
export REPLICATE_API_ENDPOINT_URL="https://api.replicate.com/v1" # optional
export REPLICATE_DREAMBOOTH_ENDPOINT_URL="https://dreambooth-api-experimental.replicate.com/v1" # optional
```

### Programmatic Configuration

Configure the client programmatically:

```ruby
Replicate.configure do |config|
  config.api_token = 'your_api_token'
end

# Run a prediction (convenience methods available directly on Replicate module)
prediction = Replicate.create_prediction(
  version: 'stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf',
  input: { prompt: 'a beautiful landscape' }
)

# Or use the client instance
prediction = Replicate.client.create_prediction(
  version: 'stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf',
  input: { prompt: 'a beautiful landscape' }
)
```

Environment variables will be used as defaults if not explicitly set in the configuration block.

## Usage

### Models and Predictions

#### Retrieving Models

```ruby
# Get the latest version of a model
model = Replicate.client.retrieve_model("stability-ai/stable-diffusion")
version = model.latest_version

# Get all versions of a model
versions = Replicate.client.retrieve_model("stability-ai/stable-diffusion", version: :all)

# Get a specific version
version = Replicate.client.retrieve_model("stability-ai/stable-diffusion", version: "some-version-id")
```

#### Running Predictions

```ruby
# Create a prediction using a model version
prediction = version.predict(prompt: "a handsome teddy bear")

# Or create directly with the client
prediction = Replicate.client.create_prediction(
  version: "stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf",
  input: { prompt: "a cat wearing a hat" }
)

# Check prediction status
puts prediction.status # "starting", "processing", "succeeded", "failed", or "canceled"

# Wait for completion and get results
prediction.refetch until prediction.finished?

if prediction.succeeded?
  output = prediction.output
  # Process your output
end
```

#### Managing Predictions

```ruby
# List recent predictions
predictions = Replicate.client.list_predictions

# Retrieve a specific prediction
prediction = Replicate.client.retrieve_prediction("prediction-id")

# Cancel a running prediction
prediction.cancel

# Use webhooks for async processing
prediction = version.predict(
  prompt: "a beautiful landscape",
  webhook: "https://your-app.com/webhooks/replicate"
)
```

### Dreambooth Training

The client supports custom model training using Replicate's Dreambooth API.

#### Uploading Training Data

```ruby
# Upload a zip file containing your training images
upload = Replicate.client.upload_zip('path/to/training_images.zip')

# The upload will have a serving URL for use in training
puts upload.serving_url
```

#### Creating Training Jobs

```ruby
training = Replicate.client.create_training(
  input: {
    instance_prompt: "photo of zwx person",
    class_prompt: "photo of person",
    instance_data: upload.serving_url,
    max_train_steps: 2000
  },
  model: 'yourusername/your-custom-model'
)

# Monitor training progress
training.refetch until training.finished?

if training.succeeded?
  # Use the trained model
  custom_version = training.version
  prediction = custom_version.predict(prompt: "photo of zwx person in Paris")
end
```

#### Converting Trained Models

After training completes, you can download the model weights and convert them to other formats:

```bash
# Download the output.zip from the training prediction
# Then convert to Stable Diffusion checkpoint format
python convert_diffusers_to_sd.py \
  --model_path ~/Downloads/output \
  --checkpoint_path ~/Downloads/model.ckpt
```

## Advanced Usage

### Caching for Performance

The client includes intelligent caching to improve performance:

```ruby
client = Replicate::Client.new(api_token: 'your_token')

# First call fetches from API
model = client.retrieve_model("stability-ai/stable-diffusion")

# Subsequent calls use cache
model2 = client.retrieve_model("stability-ai/stable-diffusion") # Cached

# Clear cache when needed
client.clear_cache
```

### Error Handling Patterns

```ruby
# Comprehensive error handling
begin
  prediction = Replicate.client.create_prediction(
    version: "stability-ai/stable-diffusion:db21e45d...",
    input: { prompt: "a beautiful sunset" }
  )

  prediction.refetch until prediction.finished?

  if prediction.succeeded?
    puts "Success! Output: #{prediction.output}"
  else
    puts "Failed: #{prediction.error}"
  end

rescue Replicate::AuthenticationError
  puts "Invalid API token"
rescue Replicate::RateLimitError
  puts "Rate limited - please wait before retrying"
  sleep 60
  retry
rescue Replicate::TimeoutError
  puts "Request timed out - try again"
rescue Replicate::APIError => e
  puts "API error (#{e.status_code}): #{e.message}"
rescue Replicate::Error => e
  puts "Unexpected error: #{e.message}"
end
```

### Working with Large Datasets

```ruby
# Upload large training datasets
upload = Replicate.client.upload_zip("path/to/large_dataset.zip")
puts "Upload URL: #{upload.serving_url}"

# Use in training
training = Replicate.client.create_training(
  input: {
    instance_prompt: "photo of person",
    class_prompt: "photo of person",
    instance_data: upload.serving_url,
    max_train_steps: 2000
  },
  model: 'your-username/custom-model'
)

# Monitor training progress
while !training.finished?
  training.refetch
  puts "Status: #{training.status} (#{training.progress || 0}%)"
  sleep 30
end
```

### Batch Processing

```ruby
# Process multiple predictions in parallel
prompts = ["cat with hat", "dog with sunglasses", "bird flying"]
predictions = []

# Start all predictions
prompts.each do |prompt|
  prediction = Replicate.client.create_prediction(
    version: "stability-ai/stable-diffusion:db21e45d...",
    input: { prompt: prompt }
  )
  predictions << prediction
end

# Wait for all to complete
until predictions.all?(&:finished?)
  predictions.each { |p| p.refetch unless p.finished? }
  sleep 5
end

# Process results
predictions.each_with_index do |prediction, index|
  if prediction.succeeded?
    puts "#{prompts[index]}: #{prediction.output.first}"
  end
end
```

### Custom Model Workflows

```ruby
# Complete workflow: upload data -> train -> use model

# 1. Upload training data
upload = Replicate.client.upload_zip("training_images.zip")

# 2. Start training
training = Replicate.client.create_training(
  input: {
    instance_prompt: "photo of zwx",
    class_prompt: "photo of person",
    instance_data: upload.serving_url,
    max_train_steps: 1000
  },
  model: 'your-username/zwx-model'
)

# 3. Wait for training completion
training.refetch until training.finished?

# 4. Use trained model
if training.succeeded?
  version = training.version
  prediction = version.predict(prompt: "zwx at the beach")
  puts prediction.output.first
end
```

## Performance Tips

- **Use caching**: The client caches model and version lookups automatically
- **Batch operations**: Group multiple predictions to reduce API calls
- **Monitor rate limits**: Handle `RateLimitError` appropriately
- **Use webhooks**: For long-running predictions, use webhooks instead of polling
- **Connection reuse**: The client maintains persistent connections for better performance

## API Reference

For comprehensive API documentation, see the [YARD documentation](https://rubydoc.info/gems/durable-replicate-ruby).

Key classes:
- `Replicate::Client` - Main client for API interactions
- `Replicate::Record::Model` - Model metadata
- `Replicate::Record::ModelVersion` - Specific model versions
- `Replicate::Record::Prediction` - Prediction jobs
- `Replicate::Record::Training` - Training jobs
- `Replicate::Record::Upload` - File uploads

## Error Handling

The client raises `Replicate::Error` for API-related errors. Always wrap API calls in error handling:

```ruby
begin
  prediction = version.predict(prompt: "test")
rescue Replicate::Error => e
  puts "API Error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Running Tests

```bash
rake test
```

### Code Quality

```bash
rake rubocop  # Check code style
rake rubocop:auto_correct  # Auto-fix style issues
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- How to report bugs
- How to request features
- How to contribute code
- Code style guidelines
- Testing requirements

## Security

This gem takes security seriously:

- **API Token Protection**: Never commit API tokens to version control
- **Input Validation**: All inputs are validated and sanitized
- **Secure Connections**: Uses HTTPS for all API communications
- **File Upload Security**: Validates file types, sizes, and content for uploads
- **Rate Limiting Awareness**: Handles API rate limits gracefully

For security-related issues, please see our [Security Policy](SECURITY.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
