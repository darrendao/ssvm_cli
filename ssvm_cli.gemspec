# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ssvm_cli"
  s.version     = "0.0.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Darren Dao"]
  s.email       = ["darrendao@gmail.com"]
  s.homepage    = "https://github.com/darrendao/ssvm_cli"
  s.summary     = %q{Ruby script to talk to ssvm web services.}
  s.description     = %q{Ruby script to talk to ssvm web services.}

  s.add_dependency 'thor'
  s.add_dependency 'json'
  s.add_dependency 'rest-client', '~> 1.6.7'
  s.add_development_dependency 'yard', '~> 0.7'

  s.files            = `git ls-files`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths    = ["lib"]
  s.extra_rdoc_files = ["README.md"]
end

