//
//  LMViewController.m
//  LMGeocoder
//
//  Created by LMinh on 03/02/2019.
//  Copyright (c) 2019 LMinh. All rights reserved.
//

#import "LMViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <LMGeocoder/LMGeocoder.h>

@interface LMViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *latitudeView;
@property (weak, nonatomic) IBOutlet UIView *longitudeView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation LMViewController

#pragma mark - VIEW LIFECYCLE

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // You can set your google API key here
    [LMGeocoder sharedInstance].googleAPIKey = nil;
    
    // Start getting current location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = 10;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    // Customize UI
    [self customizeUI];
}

- (void)customizeUI {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Black background
    self.latitudeView.layer.cornerRadius = 5;
    self.longitudeView.layer.cornerRadius = 5;
    self.addressView.layer.cornerRadius = 5;
    self.latitudeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.longitudeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.addressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    // Show camera on real device for nice effect
    BOOL hasCamera = ([[AVCaptureDevice devices] count] > 0);
    if (hasCamera) {
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
    else {
        self.backgroundImageView.image = [UIImage imageNamed:@"background"];
    }
}


#pragma mark - LOCATION MANAGER

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    // Update UI
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    // Start to reverse
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:coordinate
                                                  service:LMGeocoderServiceGoogle
                                       alternativeService:LMGeocoderServiceApple
                                        completionHandler:^(NSArray *results, NSError *error) {
                                            
                                            // Parse formatted address
                                            NSString *formattedAddress = @"-";
                                            if (results.count && !error) {
                                                LMAddress *address = [results firstObject];
                                                formattedAddress = address.formattedAddress;
                                            }
                                            NSLog(@"%@", formattedAddress);
                                            
                                            // Update UI
                                            self.addressLabel.text = formattedAddress;
                                        }];
}

@end
