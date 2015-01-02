LMGeocoder
==============
LMGeocoder is a simple wrapper for geocoding and reverse geocoding dynamically from user input. It is blocked-based geocoder, use both Google Geocoding API and Apple iOS Geocoding Framework.

![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png)

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
* Add `#include "LMGaugeView.h"` to the top of classes that will use it.

## Usage
#### Geocoding
```ObjC
[[LMGeocoder sharedInstance] geocodeAddressString:addressString
                                          service:kLMGeocoderGoogleService
                                completionHandler:^(LMAddress *address, NSError *error) {
                                    if (address && !error) {
                                        NSLog(@"Coordinate: (%f, %f)", address.coordinate.latitude, address.coordinate.longitude);
                                    }
                                    else {
                                        NSLog(@"Error: %@", error.description);
                                    }
                                }];
```

#### Reverse Geocoding
```ObjC
[[LMGeocoder sharedInstance] reverseGeocodeCoordinate:coordinate
                                              service:kLMGeocoderGoogleService
                                    completionHandler:^(LMAddress *address, NSError *error) {
                                        if (address && !error) {
                                            NSLog(@"Address: %@", address.formattedAddress);
                                        }
                                        else {
                                            NSLog(@"Error: %@", error.description);
                                        }
                                    }];
```

See sample Xcode project in `/LMGeocoderDemo`

## License
LMGeocoder is licensed under the terms of the MIT License.

## Say Hi
* [Twitter](https://twitter.com/minhluongnguyen)
* [LinkedIn](http://www.linkedin.com/in/lminh)
* [Blog](http://laptrinhiphone.blogspot.com/)
