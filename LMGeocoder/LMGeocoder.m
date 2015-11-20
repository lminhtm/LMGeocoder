//
//  LMGeocoder.m
//  LMGeocoder
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMGeocoder.h"
#import "LMAddress.h"

#define kTimeoutInterval                        60
#define kLMGeocoderErrorDomain                  @"LMGeocoderError"
#define kGoogleAPIReverseGeocodingURL(lat, lng) [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", lat, lng];
#define kGoogleAPIGeocodingURL(address)         [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", address];
#define kGoogleAPIURLWithKey(url, key)          [NSString stringWithFormat:@"%@&key=%@", url, key];

@interface LMGeocoder ()

@property (nonatomic, assign) LMGeocoderService currentService;
@property (nonatomic, strong) CLGeocoder *appleGeocoder;
@property (nonatomic, strong) NSURLSessionDataTask *googleGeocoderTask;

@property (nonatomic, assign) CLLocationCoordinate2D requestedCoordinate;
@property (nonatomic, copy) NSString *requestedAddress;
@property (nonatomic, copy) LMGeocodeCallback completionHandler;

@end

@implementation LMGeocoder

@synthesize isGeocoding = _isGeocoding;

#pragma mark - INIT

+ (LMGeocoder *)sharedInstance
{
    static LMGeocoder *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LMGeocoder alloc] init];
    });
    return sharedInstance;
}

+ (LMGeocoder *)geocoder
{
    return [[LMGeocoder alloc] init];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.appleGeocoder = [[CLGeocoder alloc] init];
    }
    return self;
}


#pragma mark - GEOCODE

- (void)geocodeAddressString:(NSString *)addressString
                     service:(LMGeocoderService)service
           completionHandler:(LMGeocodeCallback)handler
{
    // Check isGeocoding
    if (_isGeocoding) {
        return;
    }
    _isGeocoding = YES;
    
    // Store parameters
    self.requestedAddress = addressString;
    self.completionHandler = handler;
    self.currentService = service;
    
    // Check location coordinate
    if (self.requestedAddress == nil || self.requestedAddress.length == 0)
    {
        // Invalid address string --> Return error
        NSError *error = [NSError errorWithDomain:kLMGeocoderErrorDomain
                                             code:kLMGeocoderErrorInvalidAddressString
                                         userInfo:nil];
        
        [self callCompletionWithError:error];
    }
    else
    {
        // Valid location coordinate --> Check service
        switch (self.currentService)
        {
            case kLMGeocoderGoogleService:
            {
                // Geocode using Google service
                NSString *urlString = kGoogleAPIGeocodingURL(self.requestedAddress);
                if (self.googleAPIKey != nil) {
                    urlString = kGoogleAPIURLWithKey(urlString, self.googleAPIKey)
                }
                [self buildConnectionFromURLString:urlString];
                break;
            }
            case kLMGeocoderAppleService:
            {
                // Geocode using Apple service
                [self.appleGeocoder geocodeAddressString:self.requestedAddress
                                       completionHandler:^(NSArray *placemarks, NSError *error) {
                                           
                                           if (!error && placemarks.count) {
                                               // Request successful --> Parse response results
                                               [self parseGeocodingResponseResults:placemarks];
                                           }
                                           else {
                                               // Request failed --> Return error
                                               [self callCompletionWithError:error];
                                           }
                                       }];
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - REVERSE GEOCODE

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate
                         service:(LMGeocoderService)service
               completionHandler:(LMGeocodeCallback)handler
{
    // Check isGeocoding
    if (_isGeocoding) {
        return;
    }
    _isGeocoding = YES;
    
    // Store parameters
    self.requestedCoordinate = coordinate;
    self.completionHandler = handler;
    self.currentService = service;
    
    // Check location coordinate
    if (!CLLocationCoordinate2DIsValid(self.requestedCoordinate))
    {
        // Invalid location coordinate --> Return error
        NSError *error = [NSError errorWithDomain:kLMGeocoderErrorDomain
                                             code:kLMGeocoderErrorInvalidCoordinate
                                         userInfo:nil];
        
        [self callCompletionWithError:error];
    }
    else
    {
        // Valid location coordinate --> Check service
        switch (self.currentService)
        {
            case kLMGeocoderGoogleService:
            {
                // Reverse geocode using Google service
                NSString *urlString = kGoogleAPIReverseGeocodingURL(self.requestedCoordinate.latitude, self.requestedCoordinate.longitude);
                if (self.googleAPIKey != nil) {
                    urlString = kGoogleAPIURLWithKey(urlString, self.googleAPIKey)
                }

                [self buildConnectionFromURLString:urlString];
                break;
            }
            case kLMGeocoderAppleService:
            {
                // Reverse geocode using Apple service
                CLLocation *location = [[CLLocation alloc] initWithLatitude:self.requestedCoordinate.latitude
                                                                  longitude:self.requestedCoordinate.longitude];
                [self.appleGeocoder reverseGeocodeLocation:location
                                         completionHandler:^(NSArray *placemarks, NSError *error) {
                                             
                                             if (!error && placemarks.count) {
                                                 // Request successful --> Parse response results
                                                 [self parseGeocodingResponseResults:placemarks];
                                             }
                                             else {
                                                 // Request failed --> Return error
                                                 [self callCompletionWithError:error];
                                             }
                                         }];
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - CANCEL

- (void)cancelGeocode
{
    if (self.appleGeocoder) {
        [self.appleGeocoder cancelGeocode];
    }
    
    if (self.googleGeocoderTask) {
        [self.googleGeocoderTask cancel];
    }
}


#pragma mark - CONNECTION STUFF

- (void)buildConnectionFromURLString:(NSString *)urlString
{
    NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [request setTimeoutInterval:kTimeoutInterval];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    self.googleGeocoderTask = [session dataTaskWithRequest:request
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                             
                                             if (!error && data)
                                             {
                                                 // Request successful --> Parse response to JSON
                                                 NSError *error = nil;
                                                 id resultDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                 options:NSJSONReadingAllowFragments
                                                                                                   error:&error];
                                                 if (!error && resultDict && [resultDict isKindOfClass:[NSDictionary class]])
                                                 {
                                                     // Parse successful --> Check status value
                                                     NSString *status = [resultDict valueForKey:@"status"];
                                                     if ([status isEqualToString:@"OK"])
                                                     {
                                                         // Status OK --> Parse response results
                                                         NSArray *locationDicts = [resultDict objectForKey:@"results"];
                                                         [self parseGeocodingResponseResults:locationDicts];
                                                     }
                                                     else
                                                     {
                                                         // Other statuses --> Return error
                                                         [self callCompletionWithError:error];
                                                     }
                                                 }
                                                 else
                                                 {
                                                     // Parse failed --> Return error
                                                     [self callCompletionWithError:error];
                                                 }
                                             }
                                             else
                                             {
                                                 // Request failed --> Return error
                                                 [self callCompletionWithError:error];
                                             }
                                         }];
    [self.googleGeocoderTask resume];
}


#pragma mark - PARSE RESULT DATA

- (void)parseGeocodingResponseResults:(NSArray *)responseResults
{
    NSMutableArray *finalResults = [NSMutableArray new];
    
    for (id responseResult in responseResults) {
        LMAddress *address = [[LMAddress alloc] initWithLocationData:responseResult
                                                      forServiceType:self.currentService];
        [finalResults addObject:address];
    }
    
    _isGeocoding = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completionHandler) {
            self.completionHandler(finalResults, nil);
        }
    });
}

#pragma mark - SUPPORT

- (void)callCompletionWithError:(NSError *)error
{
    _isGeocoding = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completionHandler) {
            self.completionHandler(nil, error);
        }
    });
}

@end
