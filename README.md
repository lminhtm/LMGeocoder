LMGeocoder
==============
LMGeocoder is a simple wrapper for geocoding and reverse geocoding dynamically from user input. It is blocked-based geocoder, use both Google Geocoding API and Apple Geocoding Framework.

![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png)

## Installation
* Drag the `LMGeocoder` folder into your project.
* Add the <b>CoreLocation</b> to your project.
* Add the -fno-objc-arc compiler flag to SBJson files in Target Settings > Build Phases > Compile Sources.

## Requirements
LMGeocoder requires iOS 7.0 or above and ARC.

## Usage
Import the `LMGeocoder.h` header (see sample Xcode project in `/LMGeocoderDemo`)
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

## License
LMGeocoder is licensed under the terms of the MIT License.

## Say Hi
* [github.com/lminhtm](https://github.com/lminhtm)
* [twitter.com/lminhdeptrai](https://twitter.com/lminhdeptrai)
