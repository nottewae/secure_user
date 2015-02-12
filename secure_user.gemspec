$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "secure_user/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "secure_user"
  s.version     = SecureUser::VERSION
  s.authors     = ["nottewae"]
  s.email       = ["nottewae@gmail.com"]
  s.homepage    = "http://github.com/nottewae/secure_user"
  s.summary     = "////"
  s.description = "///"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"

  s.add_development_dependency "sqlite3"
end
