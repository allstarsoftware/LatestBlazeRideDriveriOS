//
//  RequestWalkCompleted.h
//  TaxiAppz Driver
//
//  Created by Spextrum on 18/01/17.
//  Copyright © 2017 Deep Gami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapper.h"

@interface RequestWalkCompleted : NSObject<RMMapping>

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
@property (nonatomic, retain) RequestWalkCompleted* walker;
@property (nonatomic, retain) RequestWalkCompleted* bill;
@property (nonatomic, retain) RequestWalkCompleted* owner;
@property (nonatomic, retain) RequestWalkCompleted* request;
@property (nonatomic, retain) RequestWalkCompleted* dog;

@end


/*
 {
 "success": true,
 "total": 25,
 "error": "Payment By cash",
 "currency": "$",
 "is_paid": 1,
 "request_id": "1162",
 "status": 1,
 "confirmed_walker": 85,
 "is_walker_started": 1,
 "is_walker_arrived": 1,
 "is_walk_started": 1,
 "is_completed": 1,
 "is_walker_rated": 0,
 {
  "walker": {
	"first_name": "Test",
	"last_name": "Driver",
	"phone": "+9190909090",
	"bio": "hjo",
	"picture": "http://www.taxiappz.com/taxidemo/public/uploads/0ece15bb02712423f3fd5924c27c8b1569411e40.jpg",
	"latitude": 11.01455791,
	"longitude": 11.01455791,
	"type": 1,
	"rating": 2.9,
	"num_rating": 40,
	"car_model": "Tyi",
	"car_number": "ryi"
 },

 "bill": {
	      "payment_mode": 1,
	      "distance": "0",
	      "unit": "kms",
	      "time": 0,
	      "base_price": 25,
	      "distance_cost": 0,
	      "time_cost": 0,
	       "walker": {
                      "email": "test@gmail.com",
                      "amount": "0"
                      },
	        "admin": {
                      "email": "admin@taxiappz.com",
                      "amount": 25
	                  },
            "currency": "$",
	        "actual_total": 25,
	        "total": 25,
	        "is_paid": 1,
	        "promo_discount": 0,
	        "main_total": 25,
	        "referral_bonus": 0,
	         "promo_bonus": 0,
	         "payment_type": 1,
	         "type": [
                      {
                       "name": "MINI",
                        "price": 0
                       }
	                 ]
             },
 
 "owner": {
	       "name": "Balance Test",
	       "picture": "",
	       "phone": "+919092292287",
	       "address": "",
	       "bio": "",
	       "latitude": 11.01698043,
           "longitude": 76.97905339,
           "owner_dist_lat": 0,
	       "owner_dist_long": 0,
	       "dest_latitude": 0,
	       "dest_longitude": 0,
	       "payment_type": 1,
	       "rating": 0,
            "num_rating": 0,
        "start_location": "Calle Cubillo, San José Province, San Pedro, Costa Rica",
        "end_location": "338, Nigeria"
 },

 "request": {
	"request_id": "1162",
	"status": 1,
	"confirmed_walker": 85,
	"is_walker_started": 1,
	"is_walker_arrived": 1,
	"is_started": 1,
	"is_walk_started": 1,
	"is_completed": 1,
	"is_dog_rated": 0,
	"is_cancelled": 0,
	"is_walker_rated": 0,
	"dest_latitude": 0,
	"dest_longitude": 0,
	"accepted_time": "2016-12-19 08:00:00",
	"payment_type": 1,
	"distance": "0.006573",
	"unit": "kms",
	"end_time": "2016-12-20 10:09:58",
	"owner": {
 "name": "Balance Test",
 "picture": "",
 "phone": "+919092292287",
 "address": "",
 "bio": "",
 "latitude": 11.01698043,
 "longitude": 76.97905339,
 "owner_dist_lat": 0,
 "owner_dist_long": 0,
 "dest_latitude": 0,
 "dest_longitude": 0,
 "payment_type": 1,
 "rating": 0,
 "num_rating": 0,
 "start_location": "Calle Cubillo, San José Province, San Pedro, Costa Rica",
 "end_location": "338, Nigeria"
	},
	"dog": [],
	"bill": {
 "payment_mode": 1,
 "distance": "0",
 "unit": "kms",
 "time": 0,
 "base_price": 25,
 "distance_cost": 0,
 "time_cost": 0,
 "walker": {
 "email": "test@gmail.com",
 "amount": "0"
 },
 "admin": {
 "email": "admin@taxiappz.com",
 "amount": 25
 },
 "currency": "$",
 "actual_total": 25,
 "total": 25,
 "is_paid": 1,
 "promo_discount": 0,
 "main_total": 25,
 "referral_bonus": 0,
 "promo_bonus": 0,
 "payment_type": 1,
 "type": [
 {
 "name": "MINI",
 "price": 0
 }
 ]
	},
	"card_details": "",
	"charge_details": {
 "unit": "kms",
 "admin_per_payment": 2.5,
 "driver_per_payment": 22.5,
 "base_price": 25,
 "distance_price": 0,
 "price_per_unit_time": 0,
 "total": 25,
 "is_paid": 1
	},
	"payment_option": 1
 }
 }

*/
