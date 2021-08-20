lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "chain_of_command/version"

Gem::Specification.new do |spec|
  spec.name          = "chain_of_command"
  spec.version       = ChainOfCommand::VERSION
  spec.authors       = ["David Sennerlöv"]
  spec.email         = ["david@protetiko.com"]

  spec.summary       = %q{Chain Usecases together to create advanced chain of code execution.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "https://protetiko.io"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "minitest", "~> 5"
end
