//
//  RequestWalkCompletedDetail.m
//  TaxiAppz Driver
//
//  Created by Spextrum on 18/01/17.
//  Copyright © 2017 Deep Gami. All rights reserved.
//

#import "RequestWalkCompletedDetail.h"
#import "RMMapper.h"
#import "RequestWalkCompleted.h"

@implementation RequestWalkCompletedDetail

- (NSArray *)rm_excludedProperties
{
    return @[@"display"];
}

@end
