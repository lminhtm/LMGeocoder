//
//  LMViewController.m
//  LMGeocoder
//
//  Created by LMinh on 01/06/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "LMGeocoder.h"

@interface LMViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation LMViewController

#pragma mark - VIEW LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start getting current location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = 100;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Show camera on real device for nice effect
    BOOL hasCamera = ([[AVCaptureDevice devices] count] > 0);
    if (hasCamera)
    {
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        session.sessionPreset = AVCaptureSessionPresetHigh;
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [captureVideoPreviewLayer setFrame:self.backgroundImageView.bounds];
        [self.backgroundImageView.layer addSublayer:captureVideoPreviewLayer];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        [session addInput:input];
        [session startRunning];
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"background"];
    }
}


#pragma mark - LOCATION MANAGER

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.longitude];

    //You can set your google API key here
    [LMGeocoder sharedInstance].googleAPIKey = @"API_KEY";
    
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:coordinate
                                                  service:kLMGeocoderGoogleService
                                        completionHandler:^(NSArray *results, NSError *error) {
                                            
                                            if (results.count && !error) {
                                                LMAddress *address = [results firstObject];
                                                self.addressLabel.text = address.formattedAddress;
                                            }
                                            else {
                                                self.addressLabel.text = @"-";
                                            }
                                            
                                            [self.addressLabel sizeToFit];
                                        }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Updating location failed");
}

@end
