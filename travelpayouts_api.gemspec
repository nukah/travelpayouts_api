lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'travelpayouts_api/version'

Gem::Specification.new do |s|
  s.name        = 'travelpayouts_api'
  s.version     = TravelPayouts::VERSION
  s.date        = '2017-01-10'
  s.summary     = 'Travelpayouts API'
  s.description = 'Ruby gem for travelpayouts api'
  s.authors     = ['Vitaly Dyatlov']
  s.email       = 'vitaly@dyatlovprojects.com'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.start_with?('spec/') }
  s.homepage    = 'http://github.com/dyatlov/travelpayouts_api'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.2.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'pry'
  s.add_dependency 'oj'
  s.add_dependency 'http'
end
