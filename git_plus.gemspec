# frozen_string_literal: true

require_relative "lib/git_plus/identity"

Gem::Specification.new do |spec|
  spec.name = GitPlus::Identity::NAME
  spec.version = GitPlus::Identity::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://github.com/bkuhlmann/git_plus"
  spec.summary = "Provides an Object API around Git."
  spec.license = "Apache-2.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/git_plus/issues",
    "changelog_uri" => "https://www.alchemists.io/projects/git_plus/changes.html",
    "documentation_uri" => "https://www.alchemists.io/projects/git_plus",
    "source_code_uri" => "https://github.com/bkuhlmann/git_plus"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.0"
  spec.add_dependency "refinements", "~> 8.0"
  spec.add_dependency "zeitwerk", "~> 2.4"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
