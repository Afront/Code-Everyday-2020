# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/forex_client/version'

Gem::Specification.new do |spec|
	spec.name          = "forex_client"
	spec.version       = ForexClient::VERSION
	spec.authors       = ["Afront"]
	spec.email         = ["3943720+Afront@users.noreply.github.com"]

	spec.summary       = %q{A forex client.}
	spec.description   = %q{A forex client that uses the Alpha Vantage API}
	spec.homepage      = "https://code-eveyday.afront.me/gems/forex_client"
	spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

	spec.metadata = {
	  "bug_tracker_uri"   => "https://github.com/Afront/forex_client/issues",
	  "changelog_uri"     => "https://github.com/Afront/forex_client/CHANGELOG.md",
#	  "documentation_uri" => "https://code-eveyday.afront.me/gems/forex_client/0.0.1",
	  "homepage_uri"      => spec.homepage,
#	  "mailing_list_uri"  => "https://code-eveyday.afront.me/forex_client",
	  "source_code_uri"   => "https://github.com/Afront/forex_client",
	  "wiki_uri"          => "https://github.com/Afront/forex_client/wiki"
	}

	spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
		`git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/})}# ; puts f }
	end

#	spec.bindir        = "bin"
	spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) } + ["forex_client"]
#	spec.executables   = ["forex_client"]
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler", "~> 2.1"
	spec.add_development_dependency "rake"
	spec.add_development_dependency "pry"
end
