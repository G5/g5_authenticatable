# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'g5_authenticatable/version'

Gem::Specification.new do |spec|
  spec.name          = 'g5_authenticatable'
  spec.version       = G5Authenticatable::VERSION
  spec.authors       = ['maeve']
  spec.email         = ['maeve.revels@getg5.com']
  spec.summary       = 'An authentication engine for G5 applications.'
  spec.description   = %q{An engine that provides a basic User model,
                          authentication logic, and remote credential
                          management for G5 applications.}
  spec.homepage      = 'https://github.com/G5/g5_authenticatable'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'devise_g5_authenticatable', '~> 0.2'
  spec.add_dependency 'g5_authenticatable_api', '~> 0.3.1'
  spec.add_dependency 'rolify', '~> 4.0'
end
