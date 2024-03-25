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
  EOF

  spec.add_dependency "rails", ">= 6.1.0"
end
