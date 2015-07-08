//
//  LMAddress.m
//  LMGeocoder
//
//  Created by LMinh on 31/05/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMAddress.h"
#import "LMGeocoder.h"

static NSString * const LMLatitudeKey            = @"latitude";
static NSString * const LMLongitudeKey           = @"longitude";
static NSString * const LMThoroughfareKey        = @"thoroughfare";
static NSString * const LMLocalityKey            = @"locality";
static NSString * const LMSubLocalityKey         = @"subLocality";
static NSString * const LMAdministrativeAreaKey  = @"administrativeArea";
static NSString * const LMPostalCodeKey          = @"postalCode";
static NSString * const LMCountryKey             = @"country";
static NSString * const LMISOCountryCodeKey      = @"ISOcountryCode";
static NSString * const LMFormattedAddressKey    = @"formattedAddress";
static NSString * const LMLinesKey               = @"lines";

#define allStringKeys @[LMThoroughfareKey, LMLocalityKey, LMSubLocalityKey, \
                        LMAdministrativeAreaKey, LMPostalCodeKey, LMCountryKey, \
                        LMISOCountryCodeKey, LMFormattedAddressKey]

@implementation LMAddress

@synthesize coordinate = _coordinate;
@synthesize thoroughfare = _thoroughfare;
@synthesize locality = _locality;
@synthesize subLocality = _subLocality;
@synthesize administrativeArea = _administrativeArea;
@synthesize postalCode = _postalCode;
@synthesize country = _country;
@synthesize ISOcountryCode = _ISOcountryCode;
@synthesize formattedAddress = _formattedAddress;
@synthesize lines = _lines;

#pragma mark - INIT

- (id)initWithLocationData:(id)locationData forServiceType:(int)serviceType
{
    self = [self init];
    if (self)
    {
        switch (serviceType)
        {
            case kLMGeocoderAppleService:
                [self setAppleLocationData:locationData];
                break;
            case kLMGeocoderGoogleService:
                [self setGoogleLocationData:locationData];
                break;
            default:
                break;
        }
    }
    return self;
}


#pragma mark - PARSING

- (void)setAppleLocationData:(id)locationData
{
    if (locationData && [locationData isKindOfClass:[CLPlacemark class]])
    {
        CLPlacemark *placemark = (CLPlacemark *)locationData;
        
        NSArray *lines = placemark.addressDictionary[@"FormattedAddressLines"];
        NSString *formattedAddress = [lines componentsJoinedByString:@", "];
        
        _coordinate = placemark.location.coordinate;
        _thoroughfare = placemark.thoroughfare;
        _locality = placemark.locality;
        _subLocality = placemark.subLocality;
        _administrativeArea = placemark.administrativeArea;
        _postalCode = placemark.postalCode;
        _country = placemark.country;
        _ISOcountryCode = placemark.ISOcountryCode;
        _formattedAddress = formattedAddress;
        _lines = lines;
    }
}

- (void)setGoogleLocationData:(id)locationData
{
    if (locationData && [locationData isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *locationDict = (NSDictionary *)locationData;
        
        NSArray *lines = locationDict[@"address_components"];
        NSString *formattedAddress = locationDict[@"formatted_address"];
        double lat = [locationDict[@"geometry"][@"location"][@"lat"] doubleValue];
        double lng = [locationDict[@"geometry"][@"location"][@"lng"] doubleValue];
        
        _coordinate = CLLocationCoordinate2DMake(lat, lng);
        _thoroughfare = [self component:@"street_number" inArray:lines ofType:@"long_name"];
        _locality = [self component:@"locality" inArray:lines ofType:@"long_name"];
        _subLocality = [self component:@"subLocality" inArray:lines ofType:@"long_name"];
        _administrativeArea = [self component:@"administrative_area_level_1" inArray:lines ofType:@"long_name"];
        _postalCode = [self component:@"postal_code" inArray:lines ofType:@"short_name"];
        _country = [self component:@"country" inArray:lines ofType:@"long_name"];
        _ISOcountryCode = [self component:@"country" inArray:lines ofType:@"short_name"];
        _formattedAddress = formattedAddress;
        _lines = lines;
    }
}

- (NSString *)component:(NSString *)component inArray:(NSArray *)array ofType:(NSString *)type
{
    NSInteger index = [array indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [(NSString *)([[obj objectForKey:@"types"] firstObject]) isEqualToString:component];
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
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LMAddress *other = object;
    
    // Lat/Long
    equal = (self.coordinate.latitude == other.coordinate.latitude);
    equal &= (self.coordinate.longitude == other.coordinate.longitude);
    
    // String values
    for (NSString *key in allStringKeys) {
        equal &= [[self valueForKey:key] isEqual:[other valueForKey:key]];
    }
    
    // Lines
    equal &= [self.lines isEqualToArray:other.lines];
    
    return equal;
}

- (NSUInteger)hash
{
    // Should be enough to hash-table well
    NSUInteger hashValue = 1;
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
        _coordinate = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:LMLatitudeKey],
                                                 [aDecoder decodeDoubleForKey:LMLongitudeKey]);
        
        // Load the strings into properties by name
        for (NSString *key in allStringKeys) {
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
        
        // Load lines array
        _lines = [aDecoder decodeObjectForKey:LMLinesKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Double
    [aCoder encodeDouble:self.coordinate.latitude forKey:LMLatitudeKey];
    [aCoder encodeDouble:self.coordinate.longitude forKey:LMLongitudeKey];
    
    // String
    for (NSString *key in allStringKeys) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
    
    // Array
    [aCoder encodeObject:self.lines forKey:LMLinesKey];
}


#pragma mark - NSCOPYING

- (id)copyWithZone:(NSZone *)zone
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

@end
