//
//  RequestWalkCompletedDetail.h
//  TaxiAppz Driver
//
//  Created by Spextrum on 18/01/17.
//  Copyright © 2017 Deep Gami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestWalkCompleted.h"

@interface RequestWalkCompletedDetail : NSObject

@property (nonatomic, strong) NSString* success;
@property (nonatomic, strong) NSString* total;
@property (nonatomic, strong) NSString* error;
@property (nonatomic, strong) NSString* currency;
@property (nonatomic, strong) NSString* is_paid;
@property (nonatomic, strong) NSString* request_id;
@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSString* confirmed_walker;
@property (nonatomic, strong) NSString* is_walker_started;
@property (nonatomic, strong) NSString* is_walker_arrived;
@property (nonatomic, strong) NSString* is_walk_started;
@property (nonatomic, strong) NSString* is_completed;
@property (nonatomic, strong) NSString* is_walker_rated;
@property (nonatomic, strong) NSString* payment_mode;
@property (nonatomic, strong) NSString* payment_option;
@property (nonatomic, retain) RequestWalkCompleted* result;
@property (nonatomic, retain) RequestWalkCompleted* bill;
@property (nonatomic, retain) RequestWalkCompleted* owner;
@property (nonatomic, retain) RequestWalkCompleted* request;
@property (nonatomic, retain) RequestWalkCompleted* dog;

@end
