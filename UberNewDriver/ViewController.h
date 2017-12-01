//
//  ViewController.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : BaseVC <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnsignin;
@property (weak, nonatomic) IBOutlet UIButton *btnregister;


@end
