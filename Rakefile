require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = ['test/**/*_spec.rb']
end
desc 'Run tests'
task default: :test
