//
//  ProviderRequestLocation.h
//  TaxiAppz Driver
//
//  Created by Spextrum on 18/01/17.
//  Copyright © 2017 Deep Gami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapper.h"

@interface ProviderRequestLocation : NSObject<RMMapping>

@property (nonatomic, strong) NSString* success;
@property (nonatomic, strong) NSString* dest_latitude;
@property (nonatomic, strong) NSString* dest_longitude;
@property (nonatomic, strong) NSString* payment_type;
@property (nonatomic, strong) NSString* is_cancelled;
@property (nonatomic, strong) NSString* distance;
@property (nonatomic, strong) NSString* unit;
@property (nonatomic, strong) NSString* time;

@end


/*
 {
 "success": true,
 "dest_latitude": 0,
 "dest_longitude": 0,
 "payment_type": 1,
 "is_cancelled": 0,
 "distance": 0,
 "unit": "kms",
 "time": 0
 }
*/
