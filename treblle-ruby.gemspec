# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'treblle/version'

Gem::Specification.new do |spec|
  spec.name        = 'treblle'
  spec.version     = Treblle::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.summary     = 'Middleware for monitoring your API endpoints'
  spec.authors     = ['Borna Kapusta']
  spec.email       = 'borna.kapusta@cactus-code.com'
  spec.homepage    = 'https://rubygems.org/gems/treblle'
  spec.license     = 'MIT'

  spec.files = Dir['lib/**/*'] + %w[MIT-LICENSE SECURITY.md README.md]

  spec.description = <<~EOF
    Treblle is a lightweight SDK that helps Engineering and Product teams
     build, ship & maintain REST based APIs faster.
     Treblle SDKs can…
     Send requests to your Treblle dashboard
     Send error to your Treblle dashboard
  EOF

  spec.required_ruby_version = '>= 2.4.0'
  spec.add_dependency 'actionpack'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'json'
  spec.add_dependency 'minitest'
  spec.add_dependency 'rake'
end
