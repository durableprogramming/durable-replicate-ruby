# frozen_string_literal: true

require_relative "lib/replicate/version"

Gem::Specification.new do |spec|
  spec.name = "durable-replicate-ruby"
  spec.version = Replicate::VERSION
  spec.authors = ["Dreaming Tulpa", "Durable Programming LLC"]
  spec.email = ["hey@dreamingtulpa.com", "commercial@durableprogramming.com"]
  spec.summary = "Ruby client for Replicate (durable fork)"
  spec.description = "A comprehensive Ruby client for Replicate's machine learning platform. " \
                     "Enables running predictions, managing models, custom model training, and file uploads " \
                     "through a clean, Ruby-native API."
  spec.homepage = "https://github.com/durableprogramming/durable-replicate-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/durableprogramming/durable-replicate-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/durableprogramming/durable-replicate-ruby/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/durable-replicate-ruby"
  spec.metadata["rubygems_mfa_required"] = "true"
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.files = files
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "addressable", "~> 2.8"
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-multipart", "~> 1.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
end
