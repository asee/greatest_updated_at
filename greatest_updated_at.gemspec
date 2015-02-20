Gem::Specification.new do |s|
  s.name = "greatest_updated_at"
  s.version = '0.1.1'
  s.date = '2015-02-19'
  s.authors = ["James Prior"]
  s.email = ["j.prior@asee.org"]
  s.summary = "Find the greatest updated_at from all included records in an AR scope"
  s.description = "An AR extension to get the most recent updated_at from an active record relation and it's included records"
  s.homepage = "https://github.com/asee/greatest_updated_at"
  s.files = Dir["{lib}/**/*.rb", "LICENSE"]
  s.add_runtime_dependency 'activerecord',  ['>= 3.2', '< 5']
  s.license = "GPL v2"
end
