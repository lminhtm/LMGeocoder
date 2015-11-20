LMGeocoder
==============
LMGeocoder is a simple wrapper for geocoding and reverse geocoding dynamically from user input. It is blocked-based geocoder, use both Google Geocoding API and Apple iOS Geocoding Framework.

![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot1.png)

## Features
* Wrapper for Geocoding and Reverse geocoding with blocked-based coding.
* Use both Google Geocoding API and Apple iOS Geocoding Framework.

## Requirements
* iOS 7.0 or higher 
* ARC

## Installation
#### From CocoaPods
```ruby
pod 'LMGeocoder'
```
#### Manually
* Drag the `LMGeocoder` folder into your project.
* Add the `CoreLocation.framework` to your project.
* Add `#import "LMGeocoder.h"` to the top of classes that will use it.

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

See sample Xcode project in `/LMGeocoderDemo`

## License
LMGeocoder is licensed under the terms of the MIT License.

## Contact
Minh Luong Nguyen
* https://github.com/lminhtm
* lminhtm@gmail.com
