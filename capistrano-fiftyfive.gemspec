# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/fiftyfive/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-fiftyfive"
  spec.version       = Capistrano::Fiftyfive::VERSION
  spec.authors       = ["Matt Brictson"]
  spec.email         = ["opensource@55minutes.com"]
  spec.description   = \
    "Capistrano 3.1+ recipes that we use at 55 Minutes to standardize "\
    "our Rails deployments. These are tailored for Ubuntu 14.04 LTS, "\
    "PostgreSQL, Nginx, Unicorn, rbenv, and Rails 3/4."
  spec.summary       = %q{Additional Capistrano recipes from 55 Minutes}
  spec.homepage      = "https://github.com/55minutes/capistrano-fiftyfive"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.2.1"
  spec.add_dependency "sshkit", ">= 1.4.0"
  spec.add_dependency "colorize"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
