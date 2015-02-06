Pod::Spec.new do |s|
  s.name             = "Abracadabra"
  s.version          = "1.0.0"
  s.summary          = "A simple and easy to use library for securing your code."
  s.homepage         = "https://github.com/shaps80/Abracadabra"
  s.license          = 'MIT'
  s.author           = { "Shaps Mohsenin" => "shapsuk@me.com" }
  s.source           = { :git => "https://github.com/shaps80/Abracadabra.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/shaps'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.dependency 'SPXDefines'
  s.dependency 'SPXDataValidators'
end
