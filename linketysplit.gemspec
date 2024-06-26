require_relative "lib/linketysplit/version"

Gem::Specification.new do |spec|
  spec.name = "linketysplit"
  spec.version = Linketysplit::VERSION
  spec.authors = ["Christopher Carson"]
  spec.email = ["chris@nowzoo.com"]

  spec.summary = "SDK for interactiong with LinketySplit"
  spec.homepage = "https://github.com/LinketySplit/linketysplit-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/LinketySplit/linketysplit-ruby/issues",
    "changelog_uri" => "https://github.com/LinketySplit/linketysplit-ruby/releases",
    "source_code_uri" => "https://github.com/LinketySplit/linketysplit-ruby",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  # spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "jwt", "~> 2.8.2"
  spec.add_dependency 'oga', '~> 3.4'
end
