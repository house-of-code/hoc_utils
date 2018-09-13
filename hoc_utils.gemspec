
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hoc_utils/version"

Gem::Specification.new do |spec|
  spec.name          = "hoc_utils"
  spec.version       = HocUtils::VERSION
  spec.authors       = ["Gert Lavsen"]
  spec.email         = ["gert@houseofcode.io"]

  spec.summary       = "Collection of utilities for the House of Code API project"
  spec.description   = "Collection of utilities for the House of Code API project"
  spec.homepage      = "https://github.com/house-of-code/hoc_utils"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "trestle"
  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
end
