//
//  LMReverseGeocoder.m
//  LMLibrary
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) Năm 2014 LMinh. All rights reserved.
//

#import "LMGeocoder.h"

#define kGoogleAPIReverseGeocodingURL(lat, lng) [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", lat, lng];
#define kGoogleAPIGeocodingURL(address)         [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", address];

@interface LMGeocoder ()
{
    NSMutableData *receivedData;
    CLLocationCoordinate2D requestedCoordinate;
    NSString *requestedAddress;
    LMGeocodeCallback completionHandler;
    LMGeocoderService currentService;
    BOOL isReverseGeocoding;
}
@end

@implementation LMGeocoder

#pragma mark - INIT

+ (LMGeocoder *)sharedInstance
{
    static LMGeocoder *instance = nil;
    if (instance == nil) {
        instance = [[LMGeocoder alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}



#pragma mark - GEOCODING

- (void)geocodeAddressString:(NSString *)addressString
                     service:(LMGeocoderService)service
           completionHandler:(LMGeocodeCallback)handler
{
    isReverseGeocoding = NO;
    requestedAddress = addressString;
    completionHandler = handler;
    currentService = service;
    
    if (requestedAddress == nil || requestedAddress.length == 0) {
        // Invalid address string, so return
        NSError *error = [NSError errorWithDomain:@"LMMapKitError" code:kLMGeocoderErrorInvalidAddressString userInfo:nil];
        
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }
    else {
        if (currentService == kLMGeocoderGoogleService) {
            // Build url string using address query
            NSString *urlString = kGoogleAPIGeocodingURL(requestedAddress);
            
            // Build connection from this url string
            [self buildConnectionFromURLString:urlString];
        }
        else {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:requestedAddress completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error) {
                    [self parseGeocodingResultData:placemarks];
                }
                else {
                    if (completionHandler) {
                        completionHandler(nil, error);
                    }
                }
            }];
        }
    }
}



#pragma mark - REVERSE GEOCODING

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate
                         service:(LMGeocoderService)service
               completionHandler:(LMGeocodeCallback)handler
{
    isReverseGeocoding = YES;
    requestedCoordinate = coordinate;
    completionHandler = handler;
    currentService = service;
    
    if (!CLLocationCoordinate2DIsValid(requestedCoordinate)) {
        // Invalid location coordinate, so return
        NSError *error = [NSError errorWithDomain:@"LMMapKitError" code:kLMGeocoderErrorInvalidCoordinate userInfo:nil];
        
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }
    else {
        if (currentService == kLMGeocoderGoogleService) {
            // Build url string using coordinate
            NSString *urlString = kGoogleAPIReverseGeocodingURL(requestedCoordinate.latitude, requestedCoordinate.longitude);
            
            // Build connection from this url string
            [self buildConnectionFromURLString:urlString];
        }
        else {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:requestedCoordinate.latitude
                                                              longitude:requestedCoordinate.longitude];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                 if (!error) {
                     [self parseGeocodingResultData:placemarks];
                 }
                 else {
                     if (completionHandler) {
                         completionHandler(nil, error);
                     }
                 }
             }];
        }
    }
}



#pragma mark - CONNECTION STUFF

/**
 * Build a connection from URL string
 */
- (void)buildConnectionFromURLString:(NSString *)urlString
{
    // Build request URL
    NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // Build NSURLRequest
    NSURLRequest *geocodingRequest = [NSURLRequest requestWithURL:requestURL
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:60.0];
    
    // Create connection and start downloading data
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:geocodingRequest delegate:self];
    if (connection) {
        // Connection valid, so init data holder
        receivedData = [NSMutableData data];
    }
    else {
        // Connection failed, so return
        NSError *error = [NSError errorWithDomain:@"LMMapKitError" code:kLMGeocoderErrorInternal userInfo:nil];
        
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }
}

/**
 *  Reset data when a new response is received
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

/**
 *  Append received data
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

/**
 * Error occurs during the transmission
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (completionHandler) {
        completionHandler(nil, error);
    }
}

/**
 *  Connection has finished and successfully downloaded the response
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Get result string
	NSString *resultString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
	// Parse result string to JSON
	NSDictionary *resultDict = [resultString JSONValue];
    
    // Parse JSON data to LMAddress
	[self parseGeocodingResultData:resultDict];
}



#pragma mark - PARSE RESULT DATA

- (void)parseGeocodingResultData:(id)resultData
{
    if (currentService == kLMGeocoderGoogleService) {
        NSDictionary *resultDict = (NSDictionary *)resultData;
        
        NSString *status = [resultDict valueForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            NSDictionary *locationDict = [[resultDict objectForKey:@"results"] objectAtIndex:0];
            NSArray *addressComponents = [locationDict objectForKey:@"address_components"];
            NSString *formattedAddress = [locationDict objectForKey:@"formatted_address"];
            double lat = [[[[locationDict objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] doubleValue];
            double lng = [[[[locationDict objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] doubleValue];
            
            LMAddress *resultAddress = [[LMAddress alloc] init];
            resultAddress.coordinate = CLLocationCoordinate2DMake(lat, lng);
            resultAddress.streetNumber = [self component:@"street_number" inArray:addressComponents ofType:@"long_name"];
            resultAddress.route = [self component:@"route" inArray:addressComponents ofType:@"long_name"];
            resultAddress.locality = [self component:@"locality" inArray:addressComponents ofType:@"long_name"];
            resultAddress.subLocality = [self component:@"subLocality" inArray:addressComponents ofType:@"long_name"];
            resultAddress.administrativeArea = [self component:@"administrative_area_level_1" inArray:addressComponents ofType:@"long_name"];
            resultAddress.postalCode = [self component:@"postal_code" inArray:addressComponents ofType:@"short_name"];
            resultAddress.country = [self component:@"country" inArray:addressComponents ofType:@"long_name"];
            resultAddress.formattedAddress = formattedAddress;
            
            if (completionHandler) {
                completionHandler(resultAddress, nil);
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:@"LMMapKitError" code:kLMGeocoderErrorInternal userInfo:nil];
            
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
    }
    else {
        NSArray *placemarks = (NSArray *)resultData;
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSArray *lines = placemark.addressDictionary[@"FormattedAddressLines"];
        
        LMAddress *resultAddress = [[LMAddress alloc] init];
        resultAddress.coordinate = placemark.location.coordinate;
        resultAddress.streetNumber = placemark.thoroughfare;
        resultAddress.locality = placemark.locality;
        resultAddress.subLocality = placemark.subLocality;
        resultAddress.administrativeArea = placemark.administrativeArea;
        resultAddress.postalCode = placemark.postalCode;
        resultAddress.country = placemark.country;
        resultAddress.formattedAddress = [lines componentsJoinedByString:@", "];
        
        if (completionHandler) {
            completionHandler(resultAddress, nil);
        }
    }
}

- (NSString *)component:(NSString *)component inArray:(NSArray *)array ofType:(NSString *)type
{
	NSInteger index = [array indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
        return [(NSString *)([[obj objectForKey:@"types"] objectAtIndex:0]) isEqualToString:component];
	}];
	
	if (index == NSNotFound) {
        return nil;
    }
	
    if (index >= array.count) {
        return nil;
    }
    
	return [[array objectAtIndex:index] valueForKey:type];
}

@end
