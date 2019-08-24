//
//  LMGeocoder.m
//  LMGeocoder
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMGeocoder.h"

@interface LMGeocoder ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation LMGeocoder

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

- (id)init
{
    self = [super init];
    if (self != nil) {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (BOOL)isGeocoding
{
    return self.operationQueue.operationCount > 0;
}


#pragma mark - GEOCODE

- (void)geocodeAddressString:(NSString *)addressString
                     service:(LMGeocoderService)service
          alternativeService:(LMGeocoderService)alternativeService
           completionHandler:(LMGeocodeCallback)completionHandler
{
    [self.operationQueue cancelAllOperations];
    
    LMGeocodingOperation *operation = [LMGeocodingOperation new];
    operation.addressString = addressString;
    operation.service = service;
    operation.alternativeService = alternativeService;
    operation.googleAPIKey = self.googleAPIKey;
    operation.completionHandler = completionHandler;
    [self.operationQueue addOperation:operation];
}


#pragma mark - REVERSE GEOCODE

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate
                         service:(LMGeocoderService)service
              alternativeService:(LMGeocoderService)alternativeService
               completionHandler:(LMGeocodeCallback)completionHandler
{
    [self.operationQueue cancelAllOperations];
    
    LMGeocodingOperation *operation = [LMGeocodingOperation new];
    operation.coordinate = coordinate;
    operation.isReverseGeocoding = YES;
    operation.service = service;
    operation.alternativeService = alternativeService;
    operation.googleAPIKey = self.googleAPIKey;
    operation.completionHandler = completionHandler;
    [self.operationQueue addOperation:operation];
}


#pragma mark - CANCEL

- (void)cancelGeocode
{
    [self.operationQueue cancelAllOperations];
}

@end
