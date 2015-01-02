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

#define kTimeoutInterval 60

@interface LMGeocoder ()
{
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
    
    if (requestedAddress == nil || requestedAddress.length == 0)
    {
        // Invalid address string, so return
        NSError *error = [NSError errorWithDomain:@"LMGeocoderError"
                                             code:kLMGeocoderErrorInvalidAddressString
                                         userInfo:nil];
        
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }
    else
    {
        if (currentService == kLMGeocoderGoogleService)
        {
            // Build url string using address query
            NSString *urlString = kGoogleAPIGeocodingURL(requestedAddress);
            
            // Build connection from this url string
            [self buildConnectionFromURLString:urlString];
        }
        else
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:requestedAddress completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error && placemarks) {
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
    
    if (!CLLocationCoordinate2DIsValid(requestedCoordinate))
    {
        // Invalid location coordinate, so return
        NSError *error = [NSError errorWithDomain:@"LMGeocoderError"
                                             code:kLMGeocoderErrorInvalidCoordinate
                                         userInfo:nil];
        
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }
    else
    {
        if (currentService == kLMGeocoderGoogleService)
        {
            // Build url string using coordinate
            NSString *urlString = kGoogleAPIReverseGeocodingURL(requestedCoordinate.latitude, requestedCoordinate.longitude);
            
            // Build connection from this url string
            [self buildConnectionFromURLString:urlString];
        }
        else
        {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:requestedCoordinate.latitude
                                                              longitude:requestedCoordinate.longitude];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                 if (!error && placemarks) {
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
   
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [request setTimeoutInterval:kTimeoutInterval];

    
    //Available since iOS5, Changed from delegate to blocks
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *reponse, NSData *data, NSError *error) {
        
        
        if (!error) {
            
            NSError *err = nil;
            //Available since iOS5, no need for SBJSON
            id resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            
            if (!err) {
                
                // Parse JSON data to LMAddress
                [self parseGeocodingResultData:resultDict];
                
            }
            
            else{
                
                if (completionHandler) {
                    completionHandler(nil, error);
                }
            }
            
        }
        else{
            
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
    }];
    
    
}



#pragma mark - PARSE RESULT DATA

- (void)parseGeocodingResultData:(id)resultData
{
    
    LMAddress *resultAddress = [[LMAddress alloc] initWithLocationData:resultData forServiceType:currentService];
    
    if (resultAddress.isValid) {

        if (completionHandler) completionHandler(resultAddress, nil);
        
        
    }else{
    
        NSError *error = [NSError errorWithDomain:@"LMMapKitError" code:kLMGeocoderErrorInternal userInfo:nil];
        
        if (completionHandler) completionHandler(nil, error);
        
    }
    
    
}


@end
