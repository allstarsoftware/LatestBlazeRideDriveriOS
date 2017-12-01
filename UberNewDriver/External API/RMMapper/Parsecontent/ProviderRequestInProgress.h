//
//  ProviderRequestInProgress.h
//  TaxiAppz Driver
//
//  Created by Spextrum on 18/01/17.
//  Copyright © 2017 Deep Gami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapper.h"

@interface ProviderRequestInProgress : NSObject<RMMapping>

@property (nonatomic, strong) NSString* request_id;
@property (nonatomic, strong) NSString* is_approved;
@property (nonatomic, strong) NSString* is_available;
@property (nonatomic, strong) NSString* is_approved_txt;
@property (nonatomic, strong) NSString* success;

@end


/*
 
 {
 "request_id": 1162,
 "is_approved": 1,
 "is_available": 1,
 "is_approved_txt": "Approved",
 "success": true
 }

*/
