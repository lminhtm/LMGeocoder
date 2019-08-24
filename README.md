# LMGeocoder
LMGeocoder is a simple wrapper for geocoding and reverse geocoding, using both Google Geocoding API and Apple iOS Geocoding Framework.

[![CI Status](https://img.shields.io/travis/LMinh/LMGeocoder.svg?style=flat)](https://travis-ci.org/LMinh/LMGeocoder)
[![Version](https://img.shields.io/cocoapods/v/LMGeocoder.svg?style=flat)](https://cocoapods.org/pods/LMGeocoder)
[![License](https://img.shields.io/cocoapods/l/LMGeocoder.svg?style=flat)](https://cocoapods.org/pods/LMGeocoder)
[![Platform](https://img.shields.io/cocoapods/p/LMGeocoder.svg?style=flat)](https://cocoapods.org/pods/LMGeocoder)

![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png)

## Features
* Wrapper for Geocoding and Reverse geocoding with blocked-based coding.
* Use both Google Geocoding API and Apple iOS Geocoding Framework.

## Requirements
iOS 8.0 or higher

## Installation
LMGeocoder is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LMGeocoder'
```

## Swift Version
https://github.com/lminhtm/LMGeocoderSwift

## Usage
#### Geocoding
```ObjC
[[LMGeocoder sharedInstance] geocodeAddressString:addressString
                                          service:LMGeocoderServiceGoogle
                               alternativeService:LMGeocoderServiceApple
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
                                              service:LMGeocoderServiceGoogle
                                   alternativeService:LMGeocoderServiceApple
                                    completionHandler:^(NSArray *results, NSError *error) {
                                        if (results.count && !error) {
                                            LMAddress *address = [results firstObject];
                                            NSLog(@"Address: %@", address.formattedAddress);
                                        }
                                    }];
```

#### Cancel Geocode
```ObjC
[[LMGeocoder sharedInstance] cancelGeocode];
```

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License
LMGeocoder is available under the MIT license. See the LICENSE file for more info.

## Author
Minh Nguyen
* https://github.com/lminhtm
* lminhtm@gmail.com
