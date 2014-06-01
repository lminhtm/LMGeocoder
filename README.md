LMGeocoder
==========
LMGeocoder is a simple wrapper for geocoding and reverse geocoding dynamically from user input. It is blocked-based geocoder, use both Google Geocoding API and MapKit framework.
![](https://raw.github.com/lminhtm/LMGeocoder/master/Screenshots/screenshot.png)

h1. Installation
* Drag the @LMGeocoder@ folder into your project.
* Add the *CoreLocation* to your project.
* Add the -fno-objc-arc compiler flag to SBJson files in Target Settings > Build Phases > Compile Sources.

h1. Requirements
LMGeocoder requires iOS 7.0 or above and ARC.

h1. Usage
h2. Geocoding
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

h2. Reverse Geocoding
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

h1. License
ReverseGeocodeCountry is licensed under the terms of the MIT License.
