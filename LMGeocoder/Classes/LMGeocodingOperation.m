//
//  LMGeocodingOperation.m
//  LMGeocoder
//
//  Created by LMinh on 8/24/19.
//

#import "LMGeocodingOperation.h"
#import "LMAddress.h"

static NSString * const LMGeocoderErrorDomain = @"LMGeocoderError";

#define kGoogleAPIReverseGeocodingURL(lat, lng) [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", lat, lng];
#define kGoogleAPIGeocodingURL(address)         [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", address];
#define kGoogleAPIURLWithKey(url, key)          [NSString stringWithFormat:@"%@&key=%@", url, key];

@interface LMGeocodingOperation ()

@property (nonatomic, strong) CLGeocoder *appleGeocoder;
@property (nonatomic, strong) NSURLSessionDataTask *googleGeocoderTask;

@end

@implementation LMGeocodingOperation

@synthesize ready = _ready;
@synthesize executing = _executing;
@synthesize finished = _finished;

#pragma mark - INIT

- (instancetype)init
{
    self = [super init];
    if (self) {
        _appleGeocoder = [[CLGeocoder alloc] init];
        _ready = YES;
    }
    return self;
}


#pragma mark - STATE

- (void)setReady:(BOOL)ready
{
    if (_ready != ready)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isReady))];
        _ready = ready;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isReady))];
    }
}

- (BOOL)isReady
{
    return _ready;
}

- (void)setExecuting:(BOOL)executing
{
    if (_executing != executing)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        _executing = executing;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    }
}

- (BOOL)isExecuting
{
    return _executing;
}

- (void)setFinished:(BOOL)finished
{
    if (_finished != finished)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
        _finished = finished;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    }
}

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isAsynchronous
{
    return YES;
}


#pragma mark - CONTROL

- (void)completeOperation
{
    if (self.executing) {
        self.executing = NO;
        self.finished = YES;
    }
}

- (void)cancel
{
    [super cancel];
    
    if (self.appleGeocoder) {
        [self.appleGeocoder cancelGeocode];
    }
    
    if (self.googleGeocoderTask) {
        [self.googleGeocoderTask cancel];
    }
    
    [self completeOperation];
}

- (void)start
{
    if (!self.isExecuting) {
        self.ready = NO;
        self.executing = YES;
        self.finished = NO;
    }
    
    if (self.isReverseGeocoding) {
        [self reverseGeocodeCoordinate:self.coordinate
                               service:self.service
                    alternativeService:self.alternativeService
                     completionHandler:self.completionHandler];
    }
    else {
        [self geocodeAddressString:self.addressString
                           service:self.service
                alternativeService:self.alternativeService
                 completionHandler:self.completionHandler];
    }
}


#pragma mark - GEOCODE

- (void)geocodeAddressString:(NSString *)addressString
                     service:(LMGeocoderService)service
          alternativeService:(LMGeocoderService)alternativeService
           completionHandler:(LMGeocodeCallback)completionHandler
{
    // Check address string
    if (addressString == nil || addressString.length == 0)
    {
        // Invalid address string --> Return error
        NSError *error = [NSError errorWithDomain:LMGeocoderErrorDomain
                                             code:LMGeocoderErrorCodeInvalidAddressString
                                         userInfo:nil];
        if (self.completionHandler && !self.isCancelled) {
            self.completionHandler(nil, error);
        }
        
        // Finish
        [self completeOperation];
    }
    else
    {
        // Valid address string --> Check service
        if (service == LMGeocoderServiceGoogle)
        {
            // Geocode using Google service
            NSString *urlString = kGoogleAPIGeocodingURL(addressString);
            if (self.googleAPIKey != nil) {
                urlString = kGoogleAPIURLWithKey(urlString, self.googleAPIKey)
            }
            [self buildAsynchronousRequestFromURLString:urlString
                                      completionHandler:^(NSArray<LMAddress *> *results, NSError *error) {
                                          
                                          if (error
                                              && !results
                                              && alternativeService != LMGeocoderServiceUndefined
                                              && !self.isCancelled) {
                                              // Retry with alternativeService
                                              [self geocodeAddressString:addressString
                                                                 service:alternativeService
                                                      alternativeService:LMGeocoderServiceUndefined
                                                       completionHandler:completionHandler];
                                          }
                                          else {
                                              // Return
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (completionHandler && !self.isCancelled) {
                                                      completionHandler(results, error);
                                                  }
                                              });
                                              
                                              // Finish
                                              [self completeOperation];
                                          }
                                      }];
        }
        else if (service == LMGeocoderServiceApple)
        {
            // Geocode using Apple service
            [self.appleGeocoder geocodeAddressString:addressString
                                   completionHandler:^(NSArray *placemarks, NSError *error) {
                                       
                                       if (error
                                           && !placemarks
                                           && alternativeService != LMGeocoderServiceUndefined
                                           && !self.isCancelled) {
                                           // Retry with alternativeService
                                           [self geocodeAddressString:addressString
                                                              service:alternativeService
                                                   alternativeService:LMGeocoderServiceUndefined
                                                    completionHandler:completionHandler];
                                       }
                                       else {
                                           // Return
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSArray *results = [self parseGeocodingResponseResults:placemarks
                                                                                              service:LMGeocoderServiceApple];
                                               if (completionHandler && !self.isCancelled) {
                                                   completionHandler(results, error);
                                               }
                                           });
                                           
                                           // Finish
                                           [self completeOperation];
                                       }
                                   }];
        }
    }
}


#pragma mark - REVERSE GEOCODE

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate
                         service:(LMGeocoderService)service
              alternativeService:(LMGeocoderService)alternativeService
               completionHandler:(LMGeocodeCallback)completionHandler
{
    // Check location coordinate
    if (!CLLocationCoordinate2DIsValid(coordinate))
    {
        // Invalid location coordinate --> Return error
        NSError *error = [NSError errorWithDomain:LMGeocoderErrorDomain
                                             code:LMGeocoderErrorCodeInvalidCoordinate
                                         userInfo:nil];
        if (completionHandler && !self.isCancelled) {
            completionHandler(nil, error);
        }
        
        // Finish
        [self completeOperation];
    }
    else
    {
        // Valid location coordinate --> Check service
        if (service == LMGeocoderServiceGoogle)
        {
            // Reverse geocode using Google service
            NSString *urlString = kGoogleAPIReverseGeocodingURL(coordinate.latitude, coordinate.longitude);
            if (self.googleAPIKey != nil) {
                urlString = kGoogleAPIURLWithKey(urlString, self.googleAPIKey)
            }
            [self buildAsynchronousRequestFromURLString:urlString
                                      completionHandler:^(NSArray<LMAddress *> *results, NSError *error) {
                                          
                                          if (error
                                              && !results
                                              && alternativeService != LMGeocoderServiceUndefined
                                              && !self.isCancelled) {
                                              // Retry with alternativeService
                                              [self reverseGeocodeCoordinate:coordinate
                                                                     service:alternativeService
                                                          alternativeService:LMGeocoderServiceUndefined
                                                           completionHandler:completionHandler];
                                          }
                                          else {
                                              // Return
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (completionHandler && !self.isCancelled) {
                                                      completionHandler(results, error);
                                                  }
                                              });
                                              
                                              // Finish
                                              [self completeOperation];
                                          }
                                      }];
        }
        else if (service == LMGeocoderServiceApple)
        {
            // Reverse geocode using Apple service
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                              longitude:coordinate.longitude];
            [self.appleGeocoder reverseGeocodeLocation:location
                                     completionHandler:^(NSArray *placemarks, NSError *error) {
                                         
                                         if (error
                                             && !placemarks
                                             && alternativeService != LMGeocoderServiceUndefined
                                             && !self.isCancelled) {
                                             // Retry with alternativeService
                                             [self reverseGeocodeCoordinate:coordinate
                                                                    service:alternativeService
                                                         alternativeService:LMGeocoderServiceUndefined
                                                          completionHandler:completionHandler];
                                         }
                                         else {
                                             // Return
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 NSArray *results = [self parseGeocodingResponseResults:placemarks
                                                                                                service:LMGeocoderServiceApple];
                                                 if (completionHandler && !self.isCancelled) {
                                                     completionHandler(results, error);
                                                 }
                                             });
                                             
                                             // Finish
                                             [self completeOperation];
                                         }
                                     }];
        }
    }
}


#pragma mark - CONNECTION STUFF

- (void)buildAsynchronousRequestFromURLString:(NSString *)urlString
                            completionHandler:(LMGeocodeCallback)handler
{
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    self.googleGeocoderTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error && data)
        {
            // Request successful --> Parse response to JSON
            NSError *parsingError = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&parsingError];
            if (!parsingError && result)
            {
                // Parse successful --> Check status value
                NSString *status = [result valueForKey:@"status"];
                if ([status isEqualToString:@"OK"])
                {
                    // Status OK --> Parse response results
                    NSArray *locationDicts = [result objectForKey:@"results"];
                    NSArray *finalResults = [self parseGeocodingResponseResults:locationDicts
                                                                        service:LMGeocoderServiceGoogle];
                    
                    if (handler) {
                        handler(finalResults, nil);
                    }
                }
                else
                {
                    // Other statuses --> Return error
                    NSError *error = [NSError errorWithDomain:LMGeocoderErrorDomain
                                                         code:LMGeocoderErrorCodeInternal
                                                     userInfo:nil];
                    if (handler) {
                        handler(nil, error);
                    }
                }
            }
            else
            {
                // Parse failed --> Return error
                if (handler) {
                    handler(nil, parsingError);
                }
            }
        }
        else
        {
            // Request failed --> Return error
            if (handler) {
                handler(nil, error);
            }
        }
    }];
    [self.googleGeocoderTask resume];
}


#pragma mark - PARSE RESULT DATA

- (NSArray *)parseGeocodingResponseResults:(NSArray *)responseResults service:(LMGeocoderService)service
{
    NSMutableArray *finalResults = [NSMutableArray new];
    
    for (id responseResult in responseResults) {
        LMAddress *address = [[LMAddress alloc] initWithLocationData:responseResult serviceType:service];
        [finalResults addObject:address];
    }
    
    return finalResults;
}

@end
