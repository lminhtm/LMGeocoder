# LMGeocoderSwift

[![CI Status](https://img.shields.io/travis/LMinh/LMGeocoderSwift.svg?style=flat)](https://travis-ci.org/LMinh/LMGeocoderSwift)
[![Version](https://img.shields.io/cocoapods/v/LMGeocoderSwift.svg?style=flat)](https://cocoapods.org/pods/LMGeocoderSwift)
[![License](https://img.shields.io/cocoapods/l/LMGeocoderSwift.svg?style=flat)](https://cocoapods.org/pods/LMGeocoderSwift)
[![Platform](https://img.shields.io/cocoapods/p/LMGeocoderSwift.svg?style=flat)](https://cocoapods.org/pods/LMGeocoderSwift)

==============
LMGeocoderSwift is a simple wrapper for geocoding and reverse geocoding, using both Google Geocoding API and Apple iOS Geocoding Framework.

![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png)

## Features
* Wrapper for Geocoding and Reverse geocoding with blocked-based coding.
* Use both Google Geocoding API and Apple iOS Geocoding Framework.

## Requirements
* iOS 8.0 or higher

## Installation
LMGeocoderSwift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LMGeocoderSwift'
```

## Usage
#### Geocoding
```Swift
LMGeocoder.sharedInstance.geocode(address: addressString,
service: .AppleService,
completionHandler: { (results: Array<LMAddress>?, error: Error?) in

// Parse formatted address
var formattedAddress: String? = "-"
if let address = results?.first, error == nil {
formattedAddress = address.formattedAddress
}

// Update UI
DispatchQueue.main.async {
self.addressLabel.text = formattedAddress
}
})
```

#### Reverse Geocoding
```Swift
LMGeocoder.sharedInstance.reverseGeocode(coordinate: coordinate,
service: .AppleService,
completionHandler: { (results: Array<LMAddress>?, error: Error?) in

// Parse formatted address
var formattedAddress: String? = "-"
if let address = results?.first, error == nil {
formattedAddress = address.formattedAddress
}

// Update UI
DispatchQueue.main.async {
self.addressLabel.text = formattedAddress
}
})
```

#### Cancel Geocode
```Swift
LMGeocoder.sharedInstance.cancelGeocode()
```

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License
LMGeocoderSwift is available under the MIT license. See the LICENSE file for more info.

## Author
Minh Luong Nguyen
* https://github.com/lminhtm
* lminhtm@gmail.com
