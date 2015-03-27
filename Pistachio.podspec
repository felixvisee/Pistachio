Pod::Spec.new do |s|
  s.name         = "Pistachio"
  s.version      = "0.1.2"
  s.summary      = "Functional model framework for Swift"
  s.description  = "Create adapters for your models functionally and type safe."
  s.homepage     = "https://github.com/felixjendrusch/Pistachio"
  s.license      = "MIT"
  s.author       = { "Felix Jendrusch" => "felix@felixjendrusch.is" }
  s.social_media_url = "http://twitter.com/felixjendrusch"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/felixjendrusch/Pistachio.git", :tag => "#{s.version}" }
  s.source_files = "Pistachio/*.swift"
  s.dependency     "LlamaKit", "~> 0.5.0"
end
