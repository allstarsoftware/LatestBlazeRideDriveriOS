//
//  RMUser.h
//  testparsecontent
//
//  Created by Spextrum on 27/12/16.
//  Copyright © 2016 InrTrade. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "RMMapper.h"

@interface RMUser : NSObject<RMMapping>

@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* picture;
@property (nonatomic, strong) NSString* bio;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* country;
@property (nonatomic, strong) NSString* zipcode;
@property (nonatomic, strong) NSString* login_by;
@property (nonatomic, strong) NSString* social_unique_id;
@property (nonatomic, strong) NSString* device_token;
@property (nonatomic, strong) NSString* device_type;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* timezone;
@property (nonatomic, strong) NSString* is_approved;
@property (nonatomic, strong) NSString* car_model;
@property (nonatomic, strong) NSString* car_number;
@property (nonatomic, strong) NSString* is_approved_txt;
@property (nonatomic, strong) NSString* is_available;


@end

/*
 
 {
 "success": true,
 "driver": {
	"id": 85,
	"first_name": "Test",
	"last_name": "Driver",
	"phone": "+9190909090",
	"email": "test@gmail.com",
	"picture": "http://www.taxiappz.com/taxidemo/public/uploads/0ece15bb02712423f3fd5924c27c8b1569411e40.jpg",
	"bio": "hjo",
	"address": "Add",
	"state": "",
	"country": "",
	"zipcode": 578,
	"login_by": "manual",
	"social_unique_id": "",
	"device_token": "fdgsdfhdfghdsg",
	"device_type": "android",
	"token": "2y1069i4KodKkYinQYWoahjVHHIREbbCBXHPHqBqkWMJOIfF3ca",
	"type": 1,
	"timezone": "UTC",
	"is_approved": true,
	"car_model": "Tyi",
	"car_number": "ryi",
	"is_approved_txt": "Approved",
	"is_available": true
 }
 }

 
*/
