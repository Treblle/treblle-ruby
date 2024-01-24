# frozen_string_literal: true

require 'rake/testtask'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = ['test/**/*_spec.rb']
end
desc 'Run tests'
task default: :test
