//
//  LMGeocoder_Tests.m
//  LMGeocoder Tests
//
//  Created by Adam Iredale on 15/01/2015.
//  Copyright (c) 2015 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LMAddress.h"

@interface LMGeocoder_Tests : XCTestCase

@end

@implementation LMGeocoder_Tests

#pragma mark - SetUp & TearDown

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Helpers

- (LMAddress *)createTestAddress
{
    // It's a block past Maple on the East end of town...
    LMAddress *address = nil;
    @autoreleasepool
    {
        address                        = [[LMAddress alloc] init];
        address.coordinate             = CLLocationCoordinate2DMake(34.151607, -118.160948);
        address.streetNumber           = @"1640";
        address.route                  = @"Riverside Drive";
        address.locality               = @"Hill Valley";
        address.subLocality            = @"Hill Valley East";
        address.administrativeArea     = @"California";
        address.postalCode             = @"91103";
        address.country                = @"United States";
        address.countryCode            = @"US";
        address.formattedAddress       = @"1640 Riverside Drive, Hill Valley CA 91103, United States";
        address.isValid                = YES;
    }
    return address;
}

#pragma mark - Tests

- (void)testValidCopyIsEqualToOriginal
{
    LMAddress *original = [self createTestAddress];
    original.isValid    = YES;
    XCTAssertEqualObjects(original, [original copy]);
}

- (void)testInvalidCopyIsEqualToOriginal
{
    LMAddress *original = [self createTestAddress];
    original.isValid    = NO;
    XCTAssertEqualObjects(original, [original copy]);
}

- (void)testAlteredCopyIsNotEqualToOriginal
{
    LMAddress *original     = [self createTestAddress];
    LMAddress *alteredCopy  = [original copy];
    alteredCopy.route       = @"John F. Kennedy Drive";
    XCTAssertNotEqualObjects(original, alteredCopy);
}

- (void)testCopyPerformance
{
    LMAddress *original = [self createTestAddress];
    [self measureBlock:^{
        [original copy];
    }];
}

@end
