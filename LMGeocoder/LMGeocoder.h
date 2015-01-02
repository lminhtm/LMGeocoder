//
//  LMReverseGeocoder.h
//  LMLibrary
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) Năm 2014 LMinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMAddress.h"

/*!
 *  LMReverseGeocoder service API
 */
typedef NS_ENUM(NSInteger, LMGeocoderService){
    kLMGeocoderGoogleService = 1,
    kLMGeocoderAppleService,
};

/*!
 *  LMReverseGeocoder error codes, embedded in NSError
 */
typedef NS_ENUM(NSInteger, LMGeocoderErrorCode){
    kLMGeocoderErrorInvalidCoordinate = 1,
    kLMGeocoderErrorInvalidAddressString,
    kLMGeocoderErrorInternal,
};

/*!
 *  Handler that reports a geocoding response, or error
 */
typedef void (^LMGeocodeCallback) (LMAddress *address, NSError *error);

/*!
 * Exposes a service for geocoding and reverse geocoding. 
 */
@interface LMGeocoder : NSObject <NSURLConnectionDelegate>

/*!
 Get shared instance
 */
+ (LMGeocoder *)sharedInstance;

/*!
 * Geocodes an address to coordinate.
 *
 * @param addressString The address string to geocode.
 * @param service The service API used to geocode.
 * @param handler The callback to invoke with the geocode results.
 *                The callback will be invoked asynchronously from the main thread.
 */
- (void)geocodeAddressString:(NSString *)addressString
                     service:(LMGeocoderService)service
           completionHandler:(LMGeocodeCallback)handler;

/*!
 * Reverse geocodes a coordinate on the Earth's surface.
 *
 * @param coordinate The coordinate to reverse geocode.
 * @param service The service API used to reverse geocode.
 * @param handler The callback to invoke with the reverse geocode results.
 *                The callback will be invoked asynchronously from the main thread.
 */
- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate
                         service:(LMGeocoderService)service
               completionHandler:(LMGeocodeCallback)handler;

@end
