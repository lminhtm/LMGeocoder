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
@synthesize countryCode;

#pragma mark - CONSTANTS

static NSString *const LMLatitudeKey            = @"latitude";
static NSString *const LMLongitudeKey           = @"longitude";
static NSString *const LMIsValidKey             = @"isValid";
static NSString *const LMStreetNumberKey        = @"streetNumber";
static NSString *const LMRouteKey               = @"route";
static NSString *const LMLocalityKey            = @"locality";
static NSString *const LMSubLocalityKey         = @"subLocality";
static NSString *const LMAdministrativeAreaKey  = @"administrativeArea";
static NSString *const LMPostalCodeKey          = @"postalCode";
static NSString *const LMCountryKey             = @"country";
static NSString *const LMFormattedAddressKey    = @"formattedAddress";
static NSString *const LMCountryCodeKey         = @"countryCode";

#define allStringKeys @[LMStreetNumberKey, LMRouteKey, LMLocalityKey, LMSubLocalityKey, \
                        LMAdministrativeAreaKey, LMPostalCodeKey, LMCountryKey, \
                        LMFormattedAddressKey, LMCountryCodeKey]

#pragma mark - INIT

- (id)init
{
    self = [super init];
    if (self) {
        self.isValid = YES;
    }
    return self;
}

- (id)initWithLocationData:(id)locationData forServiceType:(int)serviceType
{
    self = [self init];
    if (self) {
        if (serviceType == 1) {
            [self setGoogleLocationData:locationData];
        }
        else {
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
        self.isValid = YES;
        
        self.coordinate = placemark.location.coordinate;
        self.streetNumber = placemark.thoroughfare;
        self.locality = placemark.locality;
        self.subLocality = placemark.subLocality;
        self.administrativeArea = placemark.administrativeArea;
        self.postalCode = placemark.postalCode;
        self.country = placemark.country;
        self.countryCode = placemark.ISOcountryCode;
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
        self.isValid = YES;
        
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
        self.countryCode = [self component:@"country" inArray:addressComponents ofType:@"short_name"];
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


#pragma mark - EQUALITY

- (BOOL)isEqual:(id)object
{
    BOOL equal = [super isEqual:object];
    if (equal) {
        return YES;
    }
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }
    
    LMAddress *other = object;
    // Lat/Long
    equal = (self.coordinate.latitude  == other.coordinate.latitude);
    equal &= (self.coordinate.longitude == other.coordinate.longitude);
    // IsValid
    equal &= (self.isValid == other.isValid);
    // The rest
    for (NSString *key in allStringKeys) {
        equal &= [[self valueForKey:key] isEqual:[other valueForKey:key]];
    }
    
    return equal;
}

- (NSUInteger)hash
{
    // Should be enough to hash-table well
    NSUInteger hashValue = (self.isValid ? 1 : 0);
    hashValue += floor(self.coordinate.latitude) + floor(self.coordinate.longitude);
    hashValue += self.formattedAddress.hash;
    return hashValue;
}


#pragma mark - NSCODING

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        // Load doubles into coordinate
        self.coordinate = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:LMLatitudeKey],
                                                     [aDecoder decodeDoubleForKey:LMLongitudeKey]);
        
        // Load bool
        self.isValid = [aDecoder decodeBoolForKey:LMIsValidKey];
        
        // Load the strings into properties by name
        for (NSString *key in allStringKeys) {
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Double
    [aCoder encodeDouble:self.coordinate.latitude forKey:LMLatitudeKey];
    [aCoder encodeDouble:self.coordinate.longitude forKey:LMLongitudeKey];
    
    // Bool
    [aCoder encodeBool:self.isValid forKey:LMIsValidKey];
    
    // String
    for (NSString *key in allStringKeys) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}


#pragma mark - NSCOPYING

- (id)copyWithZone:(NSZone *)zone
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

@end
