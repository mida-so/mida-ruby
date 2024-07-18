Gem::Specification.new do |s|
  s.name        = 'mida'
  s.version     = '1.0.0'
  s.summary     = "Mida A/B Testing and Feature Flags"
  s.description = "A Ruby gem for Mida's A/B testing and feature flags functionality"
  s.authors     = ["Donald Ng"]
  s.email       = 'donald@mida.so'
  s.files       = ["lib/mida.rb"]
  s.homepage    = 'https://www.mida.so'
  s.license     = 'MIT'

  s.add_dependency 'json'
end