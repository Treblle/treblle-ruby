# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-performance'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc 'Run specs'
task default: :spec
