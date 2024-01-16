$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'treblle/version'

Gem::Specification.new do |s|
  s.name        = 'treblle'
  s.version     = Treblle::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Middleware for monitoring your API endpoints'
  s.authors     = ['Borna Kapusta']
  s.email       = 'borna.kapusta@cactus-code.com'
  s.homepage    = 'https://rubygems.org/gems/treblle'
  s.license     = 'MIT'

  s.files = Dir['lib/**/*'] + %w[MIT-LICENSE SECURITY.md README.md]

  s.description = <<~EOF
    Treblle is a lightweight SDK that helps Engineering and Product teams
     build, ship & maintain REST based APIs faster.
     Treblle SDKs can…
     Send requests to your Treblle dashboard
     Send error to your Treblle dashboard
  EOF

  s.required_ruby_version = '>= 2.4.0'
  s.add_development_dependency 'activesupport', '~> 6.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'json'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake'
end
