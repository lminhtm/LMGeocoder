//
//  LMAddress.m
//  LMLibrary
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) Năm 2014 LMinh. All rights reserved.
//

#import "LMAddress.h"

@implementation LMAddress

@synthesize coordinate;
@synthesize streetNumber;
@synthesize route;
@synthesize locality;
@synthesize subLocality;
@synthesize administrativeArea;
@synthesize postalCode;
@synthesize country;
@synthesize formattedAddress;
@synthesize isValid;

#pragma mark - INIT

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isValid = YES;
    }
    return self;
}

- (id)initWithLocationData:(id)locationData forServiceType:(int)serviceType
{
    self = [super init];
    if (self) {
        if (serviceType == 1) {
            [self setGoogleLocationData:locationData];
        }
        else{
            [self setAppleLocationData:locationData];
        }
    }
    return self;
}


#pragma mark - PARSING

- (void)setAppleLocationData:(id)locationData
{
    NSArray *placemarks = (NSArray *)locationData;
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    NSArray *lines = placemark.addressDictionary[@"FormattedAddressLines"];
    
    if (lines && [lines count])
    {
        self.coordinate = placemark.location.coordinate;
        self.streetNumber = placemark.thoroughfare;
        self.locality = placemark.locality;
        self.subLocality = placemark.subLocality;
        self.administrativeArea = placemark.administrativeArea;
        self.postalCode = placemark.postalCode;
        self.country = placemark.country;
        self.formattedAddress = [lines componentsJoinedByString:@", "];
    }
    else
    {
        self.isValid = NO;
    }
}

- (void)setGoogleLocationData:(id)locationData
{
    NSDictionary *resultDict = (NSDictionary *)locationData;
    NSString *status = [resultDict valueForKey:@"status"];
    
    if ([status isEqualToString:@"OK"])
    {
        NSDictionary *locationDict = [[resultDict objectForKey:@"results"] objectAtIndex:0];
        NSArray *addressComponents = [locationDict objectForKey:@"address_components"];
        NSString *formattedAddrs = [locationDict objectForKey:@"formatted_address"];
        double lat = [[[[locationDict objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] doubleValue];
        double lng = [[[[locationDict objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] doubleValue];
        
        self.coordinate = CLLocationCoordinate2DMake(lat, lng);
        self.streetNumber = [self component:@"street_number" inArray:addressComponents ofType:@"long_name"];
        self.route = [self component:@"route" inArray:addressComponents ofType:@"long_name"];
        self.locality = [self component:@"locality" inArray:addressComponents ofType:@"long_name"];
        self.subLocality = [self component:@"subLocality" inArray:addressComponents ofType:@"long_name"];
        self.administrativeArea = [self component:@"administrative_area_level_1" inArray:addressComponents ofType:@"long_name"];
        self.postalCode = [self component:@"postal_code" inArray:addressComponents ofType:@"short_name"];
        self.country = [self component:@"country" inArray:addressComponents ofType:@"long_name"];
        self.formattedAddress = formattedAddrs;
    }
    else
    {
        self.isValid = NO;
    }
}

- (NSString *)component:(NSString *)component inArray:(NSArray *)array ofType:(NSString *)type
{
	NSInteger index = [array indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
        return [(NSString *)([[obj objectForKey:@"types"] objectAtIndex:0]) isEqualToString:component];
	}];
	
	if (index == NSNotFound) {
        return nil;
    }
	
    if (index >= array.count) {
        return nil;
    }
    
	return [[array objectAtIndex:index] valueForKey:type];
}

@end
