//
//  LMAddress.h
//  LMLibrary
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) Năm 2014 LMinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LMAddress : NSObject

/** The location coordinate. */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/** The precise street address. */
@property (nonatomic, copy) NSString *streetNumber;

/** The named route. */
@property (nonatomic, copy) NSString *route;

/** The incorporated city or town political entity. */
@property (nonatomic, copy) NSString *locality;

/** The first-order civil entity below a locality. */
@property (nonatomic, copy) NSString *subLocality;

/** The civil entity below the country level. */
@property (nonatomic, copy) NSString *administrativeArea;

/** The Postal/Zip code. */
@property (nonatomic, copy) NSString *postalCode;

/** The country name. */
@property (nonatomic, copy) NSString *country;

/** The formatted address. */
@property (nonatomic, copy) NSString *formattedAddress;

@end
