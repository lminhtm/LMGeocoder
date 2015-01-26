//
//  LMAddress.h
//  LMLibrary
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) Năm 2014 LMinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LMAddress : NSObject <NSCopying, NSCoding>

/*!
*  The location coordinate
*/
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/*!
 *  The precise street address
 */
@property (nonatomic, copy) NSString *streetNumber;

/*!
 *  The named route
 */
@property (nonatomic, copy) NSString *route;

/*!
 *  The incorporated city or town political entity
 */
@property (nonatomic, copy) NSString *locality;

/*!
 *  The first-order civil entity below a localit
 */
@property (nonatomic, copy) NSString *subLocality;

/*!
 *  The civil entity below the country level
 */
@property (nonatomic, copy) NSString *administrativeArea;

/*!
 *  The Postal/Zip code
 */
@property (nonatomic, copy) NSString *postalCode;

/*!
 *  The country name
 */
@property (nonatomic, copy) NSString *country;

/*!
 *  The ISO country code (e.g. AU)
 */
@property (nonatomic, copy) NSString *countryCode;

/*!
 *  The formatted address
 */
@property (nonatomic, copy) NSString *formattedAddress;

/*!
 *  Response from server is usable
 */
@property (nonatomic, assign) BOOL isValid;

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
