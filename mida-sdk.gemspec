Gem::Specification.new do |s|
  s.name        = 'mida-sdk'
  s.version     = '1.0.1'
  s.summary     = "Mida.so A/B Testing and Feature Flags"
  s.description = "Mida.so server-side A/B Testing and Feature Flagging for Python. Start for free up to 50,000 MTU."
  s.authors     = ["Donald Ng"]
  s.email       = "donald@mida.so"
  s.files       = ["lib/mida-sdk.rb"]
  s.homepage    = 'https://www.mida.so'
  s.license     = 'MIT'

  s.add_dependency 'json'
end