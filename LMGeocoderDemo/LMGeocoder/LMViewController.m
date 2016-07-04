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
#import "LMLabel.h"

@interface LMViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *latitudeView;
@property (weak, nonatomic) IBOutlet UIView *longitudeView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet LMLabel *addressLabel;

@end

@implementation LMViewController

@synthesize backgroundImageView;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;

#pragma mark - VIEW LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // You can set your google API key here
    [LMGeocoder sharedInstance].googleAPIKey = nil;
    
    // Start getting current location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = 100;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Customize UI
    [self customizeUI];
}

- (void)customizeUI
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Black background
    self.latitudeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    self.longitudeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    self.addressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    
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
    
    // Update UI
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    // Start to reverse
    [[LMGeocoder sharedInstance] cancelGeocode];
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:coordinate
                                                  service:kLMGeocoderGoogleService
                                        completionHandler:^(NSArray *results, NSError *error) {
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (results.count && !error) {
                                                    LMAddress *address = [results firstObject];
                                                    self.addressLabel.text = address.formattedAddress;
                                                }
                                                else {
                                                    self.addressLabel.text = @"-";
                                                }
                                            });
                                        }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Updating location failed");
}

@end
