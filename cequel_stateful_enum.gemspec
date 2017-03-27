lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'cequel_stateful_enum'
  spec.version       = '1.1.0'
  spec.authors       = ['Xanders', 'Akira Matsuda']
  spec.email         = ['necropolis@inbox.ru', 'ronnie@dio.jp']

  spec.summary       = 'A state machine plugin on top of Cequel'
  spec.homepage      = 'https://github.com/Xanders/cequel_stateful_enum'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'cequel'
  spec.add_development_dependency 'rspec'
end