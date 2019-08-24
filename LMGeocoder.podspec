Pod::Spec.new do |s|
  s.name             = 'LMGeocoder'
  s.version          = '1.1.1'
  s.summary          = 'Simple wrapper for geocoding and reverse geocoding, using both Google Geocoding API and Apple iOS Geocoding Framework.'
  s.description      = <<-DESC
Simple wrapper for geocoding and reverse geocoding, written in Objective-C, using both Google Geocoding API and Apple iOS Geocoding Framework.
                       DESC

  s.homepage         = 'https://github.com/lminhtm/LMGeocoder'
  s.screenshots      = 'https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LMinh' => 'lminhtm@gmail.com' }
  s.source           = { :git => 'https://github.com/lminhtm/LMGeocoder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'LMGeocoder/Classes/**/*'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
