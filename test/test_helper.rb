# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    minimum_coverage 90
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "replicate"

require "minitest/autorun"
require "webmock/minitest"

def client
  @client ||= Replicate.client
end
