LMGeocoder
==============
LMGeocoder is a simple wrapper for geocoding and reverse geocoding dynamically from user input. It is blocked-based geocoder, use both Google Geocoding API and MapKit framework.

![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png)

## Installation
* Drag the `LMGeocoder` folder into your project.
* Add the *CoreLocation* to your project.
* Add the -fno-objc-arc compiler flag to SBJson files in Target Settings > Build Phases > Compile Sources.

## Requirements
LMGeocoder requires iOS 7.0 or above and ARC.

## Usage
#### Geocoding
<pre>
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
</pre>

#### Reverse Geocoding
<pre>
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
</pre>

## License
LMGeocoder is licensed under the terms of the MIT License.
