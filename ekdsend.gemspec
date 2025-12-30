# frozen_string_literal: true

require_relative "lib/ekdsend/version"

Gem::Specification.new do |spec|
  spec.name = "ekdsend"
  spec.version = EKDSend::VERSION
  spec.authors = ["EKD Digital"]
  spec.email = ["support@ekddigital.com"]

  spec.summary = "Official Ruby SDK for the EKDSend API"
  spec.description = "Send emails, SMS, and voice calls with the EKDSend API. Features include transactional email, bulk messaging, and voice communications."
  spec.homepage = "https://github.com/ekddigital/ekdsend-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ekddigital/ekdsend-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/ekddigital/ekdsend-ruby/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://es.ekddigital.com/docs/sdks/ruby"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 1.0", "< 3.0"
  spec.add_dependency "faraday-retry", ">= 1.0", "< 3.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
