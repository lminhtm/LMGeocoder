Pod::Spec.new do |s|

s.name              = 'LMGeocoder'
s.version           = '1.0.9'
s.summary           = 'Simple wrapper for geocoding and reverse geocoding, using both Google Geocoding API and Apple iOS Geocoding Framework.'
s.homepage          = 'https://github.com/foodora/LMGeocoder'
s.platform          = :ios, '7.0'
s.license           = {
:type => 'MIT',
:file => 'LICENSE.txt'
}
s.author            = {
'LMinh' => 'lminhtm@gmail.com'
}
s.source            = {
:git => 'https://github.com/foodora/LMGeocoder.git',
:tag => s.version.to_s
}
s.source_files      = 'LMGeocoder/*.{m,h}'
s.requires_arc      = true

end
