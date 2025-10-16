# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "yard"
YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
  t.options = ["--fail-on-warning"]
end

require "benchmark"
desc "Run performance benchmarks"
task :benchmark do
  require_relative "test/test_helper"
  require "benchmark/ips"

  puts "Running performance benchmarks..."

  Benchmark.ips do |x|
    x.config(time: 5, warmup: 2)

    x.report("Client initialization") do
      Replicate::Client.new(api_token: "test_token")
    end

    x.report("Record creation") do
      Replicate::Record::Base.new(nil, { "id" => "test", "status" => "success" })
    end

    x.compare!
  end
end

desc "Run tests with coverage"
task :coverage do
  ENV["COVERAGE"] = "true"
  Rake::Task["test"].invoke
end

task default: %i[test rubocop yard]

desc "Run security audit"
task :audit do
  require "bundler/audit/task"
  Bundler::Audit::Task.new
  Rake::Task["bundle:audit"].invoke
end

desc "Run all quality checks"
task quality: %i[test rubocop yard audit]
