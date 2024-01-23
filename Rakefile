# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = ['test/**/*_spec.rb']
end
desc 'Run tests'
task default: :test
