LMGeocoder
==============
LMGeocoder is a simple wrapper for geocoding and reverse geocoding, using both Google Geocoding API and Apple iOS Geocoding Framework.

![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png)

## Features
* Wrapper for Geocoding and Reverse geocoding with blocked-based coding.
* Use both Google Geocoding API and Apple iOS Geocoding Framework.

## Requirements
* iOS 8.0 or higher

## Installation
LMGeocoder is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:
#### Objective-C version
```ruby
pod 'LMGeocoder'
```
#### Swift version
```ruby
pod 'LMGeocoderSwift'
```

## Usage
#### Geocoding
```ObjC
[[LMGeocoder sharedInstance] geocodeAddressString:addressString
                                          service:kLMGeocoderGoogleService
                                completionHandler:^(NSArray *results, NSError *error) {
                                    if (results.count && !error) {
                                        LMAddress *address = [results firstObject];
                                        NSLog(@"Coordinate: (%f, %f)", address.coordinate.latitude, address.coordinate.longitude);
                                    }
                                }];
```
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
```ObjC
[[LMGeocoder sharedInstance] reverseGeocodeCoordinate:coordinate
                                              service:kLMGeocoderGoogleService
                                    completionHandler:^(NSArray *results, NSError *error) {
                                        if (results.count && !error) {
                                            LMAddress *address = [results firstObject];
                                            NSLog(@"Address: %@", address.formattedAddress);
                                        }
                                    }];
```
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
```ObjC
[[LMGeocoder sharedInstance] cancelGeocode];
```
```Swift
LMGeocoder.sharedInstance.cancelGeocode()
```

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License
LMGeocoder is available under the MIT license. See the LICENSE file for more info.

## Author
Minh Luong Nguyen
* https://github.com/lminhtm
* lminhtm@gmail.com

## Projects using LMGeocoder
Feel free to add your project [here](https://github.com/lminhtm/LMGeocoder/wiki/Projects-using-LMGeocoder)

## Donations
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=J3WZJT2AD28NW&lc=VN&item_name=LMGeocoder&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)
