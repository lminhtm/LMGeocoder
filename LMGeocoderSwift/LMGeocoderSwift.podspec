#
# Be sure to run `pod lib lint LMGeocoderSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LMGeocoderSwift'
  s.version          = '1.0.0'
  s.summary          = 'Simple wrapper for geocoding and reverse geocoding, using both Google Geocoding API and Apple iOS Geocoding Framework.'
  s.description      = <<-DESC
Simple wrapper for geocoding and reverse geocoding, written in Swift, using both Google Geocoding API and Apple iOS Geocoding Framework.
                       DESC

  s.homepage         = 'https://github.com/lminhtm/LMGeocoder'
  s.screenshots      = 'https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LMinh' => 'lminhtm@gmail.com' }
  s.source           = { :git => 'https://github.com/lminhtm/LMGeocoder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.0'
  
  s.source_files = 'LMGeocoderSwift/Classes/**/*'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
