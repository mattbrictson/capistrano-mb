# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/fiftyfive/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-fiftyfive"
  spec.version       = Capistrano::Fiftyfive::VERSION
  spec.author        = "Matt Brictson"
  spec.email         = "matt@mattbrictson.com"
  spec.summary       = "This gem has been renamed to capistrano-mb"
  spec.homepage      = "https://github.com/mattbrictson/capistrano-mb"
  spec.license       = "MIT"

  spec.post_install_message = "capistrano-fiftyfive has been renamed to "\
                              "capistrano-mb. Please update your Gemfile."

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.3.5"
  spec.add_dependency "sshkit", ">= 1.6.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "chandler"
  spec.add_development_dependency "rake"
end
