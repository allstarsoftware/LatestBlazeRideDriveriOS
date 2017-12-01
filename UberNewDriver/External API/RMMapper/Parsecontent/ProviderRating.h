//
//  ProviderRating.h
//  TaxiAppz Driver
//
//  Created by Spextrum on 18/01/17.
//  Copyright © 2017 Deep Gami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapper.h"

@interface ProviderRating : NSObject<RMMapping>

@property (nonatomic, strong) NSString* success;

@end

/*
 
 {
 "success": true,
 }

*/
