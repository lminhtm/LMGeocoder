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
@property (nonatomic, readonly, copy) NSString *thoroughfare;

/*!
 *  The incorporated city or town political entity.
 */
@property (nonatomic, readonly, copy) NSString *locality;

/*!
 *  The first-order civil entity below a localit.
 */
@property (nonatomic, readonly, copy) NSString *subLocality;

/*!
 *  The civil entity below the country level.
 */
@property (nonatomic, readonly, copy) NSString *administrativeArea;

/*!
 *  The Postal/Zip code.
 */
@property (nonatomic, readonly, copy) NSString *postalCode;

/*!
 *  The country name.
 */
@property (nonatomic, readonly, copy) NSString *country;

/*!
 *  The ISO country code.
 */
@property (nonatomic, readonly, copy) NSString *ISOcountryCode;

/*!
 *  The formatted address.
 */
@property (nonatomic, readonly, copy) NSString *formattedAddress;

/*!
 *  An array of NSString containing formatted lines of the address.
 */
@property(nonatomic, readonly, copy) NSArray *lines;

/*!
 *  Initialize with response from server
 *
 *  @param locationData response object recieved from server
 *  @param serviceType  pass here kLMGeocoderGoogleService or kLMGeocoderAppleService
 *
 *  @return object with all data set for use
 */
- (id)initWithLocationData:(id)locationData forServiceType:(int)serviceType;

@end
