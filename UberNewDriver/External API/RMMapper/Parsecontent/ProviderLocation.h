//
//  ProviderLocation.h
//  TaxiAppz Driver
//
//  Created by Spextrum on 18/01/17.
//  Copyright © 2017 Deep Gami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapper.h"

@interface ProviderLocation : NSObject<RMMapping>

@property (nonatomic, strong) NSString* success;
@property (nonatomic, strong) NSString* is_active;
@property (nonatomic, strong) NSString* is_approved;
@property (nonatomic, strong) NSString* is_active_txt;

@end


/*
 
 {
 "success": true,
 "is_active": 1,
 "is_approved": 1,
 "is_active_txt": "active"
 }

 
*/
