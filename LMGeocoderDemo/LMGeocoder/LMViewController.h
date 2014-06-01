//
//  LMViewController.h
//  LMGeocoder
//
//  Created by LMinh on 01/06/2014.
//  Copyright (c) Năm 2014 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "LMAddress.h"
#import "LMGeocoder.h"

@interface LMViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@end
