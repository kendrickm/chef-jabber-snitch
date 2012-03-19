Gem::Specification.new do |s|
  s.name        = "chef-jabber-snitch"
  s.version     = "0.0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alice Kaerast"]
  s.email       = ["alice.kaerast@webanywhere.co.uk"]
  s.homepage    = "https://github.com/kaerast/chef-jabber-snitch"
  s.summary     = %q{An exception handler for OpsCode Chef runs (GitHub Gists & Jabber)}
  s.description = %q{An exception handler for OpsCode Chef runs (GitHub Gists & Jabber)}
  s.has_rdoc    = false
  s.license     = "MIT"

  #s.rubyforge_project = "chef-irc-snitch"

  s.add_dependency('chef')
  #s.add_dependency('carrier-pigeon')
  s.add_dependency('xmpp4r')

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
