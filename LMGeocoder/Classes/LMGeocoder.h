//
//  LMGeocoder.h
//  LMGeocoder
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LMAddress.h"
#import "LMGeocodingOperation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Exposes a service for geocoding and reverse geocoding.
 */
@interface LMGeocoder : NSObject

/**
 *  Indicating whether the receiver is in the middle of geocoding its value.
 */
@property (nonatomic, assign, readonly) BOOL isGeocoding;

/**
 *  To set google API key
 */
@property (nonatomic, strong, nullable) NSString *googleAPIKey;

/**
 *  Get shared instance.
 */
+ (LMGeocoder *)sharedInstance;

/**
 *  Submits a forward-geocoding request using the specified string.
 *  After initiating a forward-geocoding request, do not attempt to initiate another forward- or reverse-geocoding request.
 *  Geocoding requests are rate-limited for each app, so making too many requests in a short period of time may cause some of the requests to fail. 
 *  When the maximum rate is exceeded, the geocoder passes an error object to your completion handler.
 *
 *  @param addressString        The string describing the location you want to look up.
 *  @param service              The service API used to geocode.
 *  @param alternativeService   The service API will be used if service API failed. LMGeocoderServiceUndefined means no alternative.
 *  @param completionHandler    The callback to invoke with the geocode results. The callback will be invoked asynchronously from the main thread.
 */
- (void)geocodeAddressString:(NSString *)addressString
                     service:(LMGeocoderService)service
          alternativeService:(LMGeocoderService)alternativeService
           completionHandler:(nullable LMGeocodeCallback)completionHandler;

/**
 *  Submits a reverse-geocoding request for the specified coordinate.
 *  After initiating a reverse-geocoding request, do not attempt to initiate another reverse- or forward-geocoding request.
 *  Geocoding requests are rate-limited for each app, so making too many requests in a short period of time may cause some of the requests to fail. 
 *  When the maximum rate is exceeded, the geocoder passes an error object to your completion handler.
 *
 *  @param coordinate           The coordinate to look up.
 *  @param service              The service API used to reverse geocode.
 *  @param alternativeService   The service API will be used if service API failed. LMGeocoderServiceUndefined means no alternative.
 *  @param completionHandler    The callback to invoke with the reverse geocode results. The callback will be invoked asynchronously from the main thread.
 */
- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate
                         service:(LMGeocoderService)service
              alternativeService:(LMGeocoderService)alternativeService
               completionHandler:(nullable LMGeocodeCallback)completionHandler;

/**
 *  Cancels a pending geocoding request.
 */
- (void)cancelGeocode;

@end

NS_ASSUME_NONNULL_END
