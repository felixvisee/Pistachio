Pod::Spec.new do |s|
  s.name          = 'Pistachio'
  s.version       = '0.1.1-a2'
  s.summary       = 'Generic model framework for Swift'
  s.homepage      = 'https://github.com/a2/Pistachio'
  s.license       = 'MIT'
  s.author        = { 'Felix Jendrusch' => 'felix@felixjendrusch.is',
                      'Robert Böhnke' => 'robb@robb.is' }
  s.source        = { :git => 'https://github.com/a2/Pistachio.git', :tag => s.version }
  s.source_files  = 'Pistachio/*.{h,swift}'
  s.dependency      'LlamaKit', '~> 0.6.0'
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
end
