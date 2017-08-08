//
//  LMAddress.h
//  LMGeocoder
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/*!
 *  A result from a reverse geocode request, containing a human-readable address.
 *  Some of the fields may be nil, indicating they are not present.
 */
@interface LMAddress : NSObject <NSCopying, NSCoding>

/*!
 *  The location coordinate
 */
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;

/*!
 *  The precise street address.
 */
@property (nonatomic, readonly, copy, nullable) NSString *streetNumber;

/*!
 *  The named route.
 */
@property (nonatomic, readonly, copy, nullable) NSString *route;

/*!
 *  The incorporated city or town political entity.
 */
@property (nonatomic, readonly, copy, nullable) NSString *locality;

/*!
 *  The first-order civil entity below a localit.
 */
@property (nonatomic, readonly, copy, nullable) NSString *subLocality;

/*!
 *  The civil entity below the country level.
 */
@property (nonatomic, readonly, copy, nullable) NSString *administrativeArea;

/*!
 *  The additional administrative area information.
 */
@property (nonatomic, readonly, copy, nullable) NSString *subAdministrativeArea;

/*!
 *  The Postal/Zip code.
 */
@property (nonatomic, readonly, copy, nullable) NSString *postalCode;

/*!
 *  The country name.
 */
@property (nonatomic, readonly, copy, nullable) NSString *country;

/*!
 *  The ISO country code.
 */
@property (nonatomic, readonly, copy, nullable) NSString *ISOcountryCode;

/*!
 *  The formatted address.
 */
@property (nonatomic, readonly, copy, nullable) NSString *formattedAddress;

/*!
 *  An array of NSString containing formatted lines of the address.
 */
@property (nonatomic, readonly, copy, nullable) NSArray<NSString *> *lines;

/*!
 * Raw google address
 */
@property (nonatomic, readonly, copy, nullable) NSArray *googleAddressComponents;

/*!
 *  Initialize with response from server
 *
 *  @param locationData response object recieved from server
 *  @param serviceType  pass here kLMGeocoderGoogleService or kLMGeocoderAppleService
 *
 *  @return object with all data set for use
 */
- (nonnull id)initWithLocationData:(nonnull id)locationData forServiceType:(int)serviceType;

@end
