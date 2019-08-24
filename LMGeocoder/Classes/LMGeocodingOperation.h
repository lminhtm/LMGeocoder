//
//  LMGeocodingOperation.h
//  LMGeocoder
//
//  Created by LMinh on 8/24/19.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LMAddress.h"

/**
 *  LMGeocoder service API.
 */
typedef enum : NSUInteger {
    LMGeocoderServiceUndefined,
    LMGeocoderServiceGoogle,
    LMGeocoderServiceApple,
} LMGeocoderService;

/**
 *  LMGeocoder error codes, embedded in NSError.
 */
typedef enum : NSUInteger {
    LMGeocoderErrorCodeInvalidCoordinate,
    LMGeocoderErrorCodeInvalidAddressString,
    LMGeocoderErrorCodeInternal,
} LMGeocoderErrorCode;

/**
 *  Handler that reports a geocoding response, or error.
 */
typedef void (^LMGeocodeCallback) (NSArray<LMAddress *> * _Nullable results,  NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface LMGeocodingOperation : NSOperation

@property (nonatomic, copy) NSString *addressString;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) BOOL isReverseGeocoding;
@property (nonatomic, assign) LMGeocoderService service;
@property (nonatomic, assign) LMGeocoderService alternativeService;
@property (nonatomic, strong, nullable) NSString *googleAPIKey;
@property (nonatomic, copy, nullable) LMGeocodeCallback completionHandler;

@end

NS_ASSUME_NONNULL_END
