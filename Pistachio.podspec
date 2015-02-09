Pod::Spec.new do |s|
  s.name         = "Pistachio"
  s.version      = "0.0.1"
  s.summary      = "Functional model framework for Swift"
  s.description  = <<-DESC
                   Create adapters for your models functionally and type safe.
                   DESC

  s.homepage     = "https://github.com/felixjendrusch/Pistachio"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Felix Jendrusch" => "felix@felixjendrusch.is" }
  s.social_media_url   = "http://twitter.com/felixjendrusch"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "http://github.com/felixjendrusch/Pistachio.git", :tag => "#{s.version}" }
  s.source_files  = "Pistachio/*.swift"
  s.requires_arc = true
  s.dependency "LlamaKit", "~> 0.5.0"
end
