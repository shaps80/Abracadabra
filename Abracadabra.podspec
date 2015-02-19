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
  s.dependency 'SPXDefines'
  s.dependency 'SPXDataValidators'

  s.subspec 'Core' do |spec|
    spec.source_files = 'Pod/Classes/Core/**/*.{h,m}'
  end

  s.subspec 'UI' do |spec|
    spec.source_files = 'Pod/Classes/UI/**/*.{h,m}'
    spec.dependency 'Abracadabra/Core'
  end
end
