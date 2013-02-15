Gem::Specification.new do |s|
  s.name        = "chef-jabber-snitch"
  s.version     = "1.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kendrick Martin"]
  s.email       = ["kendrick.martin@webtrends.com"]
  s.homepage    = "https://github.com/kaerast/chef-jabber-snitch"
  s.summary     = %q{An exception handler for OpsCode Chef runs (Pastebin & Jabber)}
  s.description = %q{An exception handler for OpsCode Chef runs (Pastebin & Jabber)}
  s.has_rdoc    = false
  s.license     = "MIT"

  s.add_dependency('chef')
  s.add_dependency('xmpp4r')

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
